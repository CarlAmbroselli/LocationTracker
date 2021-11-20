//
//  DropboxViewModel.swift
//

import SwiftUI
import SwiftyDropbox

/// A ViewModel that publishes data retrieved from DropboxModel. Each View will have its own ViewModel.
class DropboxViewModel: ObservableObject {
    
    @Published var showAuthenticateDropbox = DropboxModel.shared.needsAuth
    @Published var status = DropboxModel.shared.state
    private var authenticationTriggered = false
    
    private let dropboxModel = DropboxModel.shared
    
    func updateDropboxState() throws {
        dropboxModel.updateDropboxState()
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
}
