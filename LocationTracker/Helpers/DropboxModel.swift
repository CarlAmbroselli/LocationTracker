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
    
    func updateDropboxState(callback: @escaping (Bool) -> Void) {
        print("updateDropboxState")
        guard let client = DropboxClientsManager.authorizedClient else {
            print("failed to init client!")
            return
        }
        client.files.listFolder(path: "").response { response, error in
            if let result = response {
                print(result)
                callback(true)
            } else {
                print(error)
                callback(false)
            }
        }
    }
    
}
