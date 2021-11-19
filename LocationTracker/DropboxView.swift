//
//  DropboxView.swift
//  LocationTracker
//
//  Created by Carl on 18.11.21.
//

import Foundation
import SwiftUI
import SwiftyDropbox

struct DropboxView : View {
    @State var isShown = false
    @ObservedObject var viewModel = DropboxViewModel()
    
    var body : some View {
        VStack {
            Button(action: {
                self.isShown.toggle()
            }) {
                Text("Authenticate Dropbox")
            }
            DropboxViewController(isShown: $isShown)
            VStack {
                if viewModel.hasContent {
                    
                    Text("hasContent")
                    
                } else if viewModel.gettingData {

                    Text("gettingData")
                    
                } else if viewModel.hasError {
                    
                    Text("errorView")
                }
            }
            .onAppear() {
                print("load my friend")
                let _ = DropboxModel.shared
                guard let client = DropboxClientsManager.authorizedClient else {
                    print("failed to init client!")
                    return
                }
                
                client.users.getCurrentAccount().response { response, error in
                    print(response)
                    print(error)
                }
            }
        }
        .onOpenURL { url in
            DropboxClientsManager.handleRedirectURL(url, completion: { result in
                print("Authenticated with dropbox")
                if viewModel.path == nil { viewModel.path = "/" }
                try? viewModel.getDropboxContent()
            })
        }
    }
}

struct DropboxViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    @Binding var isShown : Bool

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isShown {
            print("Auth!")
            let _ = DropboxModel.shared
            let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read", "files.content.read", "files.metadata.read"], includeGrantedScopes: false)
            DropboxClientsManager.authorizeFromControllerV2(
                UIApplication.shared,
                controller: uiViewController,
                loadingStatusDelegate: nil,
                openURL: { (url: URL) -> Void in
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                },
                scopeRequest: scopeRequest
            )
        }
    }

    func makeUIViewController(context _: Self.Context) -> UIViewController {
        return UIViewController()
    }
}
