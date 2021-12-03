//
//  DropboxModel.swift
//  LocationTracker
//
//  Created by Carl on 19.11.21.
//

import Foundation
import SwiftyDropbox
import CoreData

class DropboxModel {
    
    static let shared: DropboxModel = {
        let instance = DropboxModel()
        DropboxClientsManager.setupWithAppKey("xc7j7zq6qdeb0tb")
        return instance
    }()
    
    var state: String = "Uninitialized"
    
    func updateDropboxState(resultHandler: @escaping (Bool, String) -> Void) {
        print("updateDropboxState")
        guard let client = DropboxClientsManager.authorizedClient else {
            print("failed to init client!")
            state = "Failed to initialize client"
            return
        }
        client.users.getCurrentAccount().response { response, error in
            if let account = response {
                resultHandler(true, "Authenticated \(account.name.givenName)")
            } else {
                resultHandler(false, error?.description ?? "no error")
            }
        }
    }
    
    func uploadLocations(updateProgress: @escaping (_ all: Int, _ uploaded: Int, _ results: [File]) -> Void) {
        let timestampSort = NSSortDescriptor(key:"timestamp", ascending:true)
        let fetchRequest = Location.fetchRequest() as NSFetchRequest<Location>
        fetchRequest.sortDescriptors = [timestampSort]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let asyncFetch = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { result in

            guard let locations = result.finalResult else {
              print("Failed to fetch locations")
              return
            }
            
            var uploaded = 0
            var total = 0
            var lastDate = ""
            var currentCsv = ""
            let fields = ["date", "timestamp", "longitude", "latitude", "altitude", "floor", "horizontalAccuracy", "verticalAccuracy"]
            var results: [File] = []
            var delay = 0.0
        
            locations.forEach({ location in
                guard let thisDate = location.date else {
                    return
                }
                if (lastDate != thisDate) {
                    if (!currentCsv.isEmpty) {
                        total += 1
                        let dateToUpload = lastDate
                        let csvToUpload = currentCsv
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.storeDay(csv: csvToUpload, date: dateToUpload) { result in
                                results.append(File(status: result, path: dateToUpload))
                                uploaded += 1
                                updateProgress(total, uploaded, results)
                            }
                        }
                        delay += 1
                    }
                    lastDate = thisDate
                    currentCsv = fields.joined(separator: ";")
                }
                currentCsv += "\n" + fields.map({ field in
                    if (field == "timestamp") {
                        guard let timestamp = location.timestamp else {
                            return ""
                        }
                        return "\(Int(timestamp.timeIntervalSince1970))"
                    } else {
                        return "\(location.value(forKey: field) ?? "")"
                    }
                }).joined(separator: ";")
            })
            
        }
        
        do {
            let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
            try backgroundContext.execute(asyncFetch)
        } catch let error {
            print("Error!!", error)
        }
    }
    
    func storeDay(csv: String, date: String, completionHandler: @escaping (FileStatus) -> Void) {
        let fileData = csv.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        guard let client = DropboxClientsManager.authorizedClient else {
            print("client not initialized")
            return
        }

        client.files.upload(path: "/data/locations/location-tracker/\(date).csv", mode: Files.WriteMode.overwrite, autorename: false, clientModified: nil, mute: true, propertyGroups: nil, strictConflict: false, input: fileData)
            .response { response, error in
                if let response = response {
                    completionHandler(FileStatus.success)
                    print(response)
                } else if let error: CallError<Files.UploadError> = error {
                    switch error {
                        case let .routeError(_, _, summary, _):
                        guard let summaryText = summary else {
                            completionHandler(.unhandledError("routeError"))
                            return
                        }
                        if (summaryText.contains("conflict")) {
                            completionHandler(.conflict)
                        }
                        case .internalServerError(_, _, _):
                            completionHandler(.unhandledError("internalServerError"))
                        case .badInputError(_, _):
                            completionHandler(.unhandledError("badInputError"))
                        case .rateLimitError(_, _, _, _):
                            completionHandler(.unhandledError("rateLimitError"))
                        case .httpError(_, _, _):
                            completionHandler(.unhandledError("httpError"))
                        case .authError(_, _, _, _):
                            completionHandler(.unhandledError("authError"))
                        case .accessError(_, _, _, _):
                            completionHandler(.unhandledError("accessError"))
                        case .clientError(_):
                            completionHandler(.unhandledError("clientError"))
                    }
                    
                }
            }
            .progress { progressData in
                print(progressData)
            }
    }
    
}

struct File: Identifiable {
    var id: String {
        path
    }
    
    let status: FileStatus
    let path: String
}

enum FileStatus: CustomStringConvertible {
    case success
    case conflict
    case unhandledError(String)
    
    var description: String {
        get {
          switch self {
            case .success:
              return "✅"
            case .conflict:
              return "conflict"
          case .unhandledError(let error):
              return error
          }
        }
      }
}
