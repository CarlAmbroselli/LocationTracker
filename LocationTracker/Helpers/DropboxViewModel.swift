//
//  DropboxViewModel.swift
//

import SwiftUI
import SwiftyDropbox

/// A ViewModel that publishes data retrieved from DropboxModel. Each View will have its own ViewModel.
class DropboxViewModel: ObservableObject {
    
    @Published var showAuthenticateDropbox = DropboxModel.shared.needsAuth
    @Published var status = DropboxModel.shared.state
    
    private let dropboxModel = DropboxModel.shared
    
    func updateDropboxState() throws {
        dropboxModel.updateDropboxState()
    }
}
