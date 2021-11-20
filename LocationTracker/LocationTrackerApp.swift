//
//  LocationTrackerApp.swift
//  LocationTracker
//

import Combine
import SwiftUI

@main
struct LocationTrackerApp: App {
    let locationPublisher = LocationPublisher()
    var cancellables = [AnyCancellable]()
    let model = ViewModel()
    
    init() {
        locationPublisher.sink(receiveValue: PersistenceController.shared.add).store(in: &cancellables)
    }
    
    var body: some Scene {
        WindowGroup {
            StorylineView(viewModel: model)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
