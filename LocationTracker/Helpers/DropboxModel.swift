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
    
    var needsAuth: Bool {
        return DropboxClientsManager.authorizedClient == nil
    }
    
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
    
    func uploadLocations(updateProgress: @escaping (_ all: Int, _ uploaded: Int) -> Void) {
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
            var results: [Bool] = []
            var delay = 0.0
        
            locations.forEach({ location in
                guard let thisDate = location.date else {
                    return
                }
                if (lastDate != thisDate) {
                    total += 1
                    if (!currentCsv.isEmpty) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.storeDay(csv: currentCsv, date: lastDate) { result in
                                results.append(result)
                                uploaded += 1
                                updateProgress(total, uploaded)
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
        } catch _ {
          // handle error
        }
    }
    
    func storeDay(csv: String, date: String, completionHandler: @escaping (Bool) -> Void) {
        let fileData = csv.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        guard let client = DropboxClientsManager.authorizedClient else {
            print("client not initialized")
            return
        }

        client.files.upload(path: "/data/locations/location-tracker/\(date).csv", input: fileData)
            .response { response, error in
                if let response = response {
                    completionHandler(true)
                    print(response)
                } else if let error = error {
                    completionHandler(false)
                    print(error)
                }
            }
            .progress { progressData in
                print(progressData)
            }
    }
    
}
