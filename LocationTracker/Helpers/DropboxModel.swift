//
//  DropboxModel.swift
//  LocationTracker
//
//  Created by Carl on 19.11.21.
//

import Foundation
import SwiftyDropbox

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
    
    func updateDropboxState() {
        print("updateDropboxState")
        guard let client = DropboxClientsManager.authorizedClient else {
            print("failed to init client!")
            state = "Failed to initialize client"
            return
        }
        client.files.listFolder(path: "").response { response, error in
            if let result = response {
                self.state = "Loaded"
                print(result)
            } else {
                print(error)
            }
        }
    }
    
}
