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
            Text(viewModel.status)
            DropboxViewController(isShown: $viewModel.showAuthenticateDropbox, viewModel: viewModel)
        }
        .onAppear() {
            if DropboxClientsManager.authorizedClient == nil {
                viewModel.showAuthenticateDropbox = true
            } else {
                try? viewModel.updateDropboxState()
            }
        }
        .onOpenURL { url in
            print("Received url: \(url)")
            DropboxClientsManager.handleRedirectURL(url, completion: { result in
                print("Result:")
                print(result)
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
