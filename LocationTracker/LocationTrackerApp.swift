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
    
    init() {
        locationPublisher.sink(receiveValue: PersistenceController.shared.add).store(in: &cancellables)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
