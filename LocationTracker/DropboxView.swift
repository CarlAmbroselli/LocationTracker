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
    @ObservedObject var viewModel: DropboxViewModel
    
    var body : some View {
        VStack {
            Text(viewModel.authenticationStatus)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isAuthenticated ? .green : .orange)
            Spacer()
            DropboxViewController(isShown: $viewModel.showAuthenticateDropbox, viewModel: viewModel)
            if (viewModel.isAuthenticated) {
                
                Text(viewModel.syncStatus)
                
                Spacer().frame(height: 50)
                
                HStack {
                    Spacer()
                
                    Button(action: {
                        viewModel.uploadLocations()
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Sync Locations")
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.uploadLocations()
                    }) {
                        HStack {
                            Image(systemName: "lock")
                            Text("Logout Dropbox")
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                }
            }
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            if DropboxClientsManager.authorizedClient == nil {
                viewModel.showAuthenticateDropbox = true
            } else {
                try? viewModel.updateDropboxState()
            }
        }
        .onOpenURL { url in
            DropboxClientsManager.handleRedirectURL(url, completion: { result in
                try? viewModel.updateDropboxState()
            })
        }
    }
}

struct DropboxViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    @Binding var isShown : Bool
    var viewModel: DropboxViewModel

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isShown {
            viewModel.authenticate(controller: uiViewController)
        }
    }

    func makeUIViewController(context _: Self.Context) -> UIViewController {
        return UIViewController()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DropboxView(viewModel: ViewModel.dropboxViewModel)
    }
}
