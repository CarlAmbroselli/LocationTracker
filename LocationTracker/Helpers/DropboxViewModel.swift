//
//  DropboxViewModel.swift
//

import SwiftUI
import SwiftyDropbox

/// A ViewModel that publishes data retrieved from DropboxModel. Each View will have its own ViewModel.
class DropboxViewModel: ObservableObject {
    
    @Published var showAuthenticateDropbox = DropboxModel.shared.needsAuth
    @Published var authenticationStatus = "Loading..."
    @Published var isAuthenticated = false
    private var authenticationTriggered = false
    
    private let dropboxModel = DropboxModel.shared
    
    func updateDropboxState() throws {
        dropboxModel.updateDropboxState() { isAuthenticated, authenticationStatus in
            self.isAuthenticated = isAuthenticated
            self.authenticationStatus = authenticationStatus
        }
    }
    
    func authenticate(controller: UIViewController?) {
        if (!authenticationTriggered) {
            authenticationTriggered = true
            let scopeRequest = ScopeRequest(scopeType: .user, scopes: [
                "account_info.read",
                "files.content.read",
                "files.metadata.read"
            ], includeGrantedScopes: false)
            DropboxClientsManager.authorizeFromControllerV2(
                UIApplication.shared,
                controller: controller,
                loadingStatusDelegate: nil,
                openURL: { (url: URL) -> Void in
                    print(url)
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                },
                scopeRequest: scopeRequest
            )
        }
    }
    
    func uploadLocations() {
        dropboxModel.uploadLocations()
    }
}
