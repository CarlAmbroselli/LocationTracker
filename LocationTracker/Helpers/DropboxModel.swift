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
    
    func uploadLocations() {
        let fetchRequest = Location.fetchRequest() as NSFetchRequest<Location>
        
        let asyncFetch = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) {
            [weak self] result in

            guard let locations = result.finalResult else {
              print("Failed to fetch locations")
              return
            }
            
            print("Locations to update")
            print(locations.map({ location in
                return location.longitude
            }).count)
            
        }
        
        do {
            let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
            try backgroundContext.execute(asyncFetch)
        } catch let error {
          // handle error
        }
    }
    
}
