//
//  DropboxViewModel.swift
//

import SwiftUI
import SwiftyDropbox

/// A ViewModel that publishes data retrieved from DropboxModel. Each View will have its own ViewModel.
class DropboxViewModel: ObservableObject {
    
    @Published var syncedDays = [String]()
    @Published var status = "Loading..."
    @Published var showAuthenticateDropbox = false
    private let dropboxModel = DropboxModel.shared
    
    func updateDropboxState() throws {
        dropboxModel.updateDropboxState(callback: { state in
            self.showAuthenticateDropbox = !state
            self.status = "Loaded"
        })
    }
}
