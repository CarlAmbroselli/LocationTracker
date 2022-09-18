//
//  Persistence.swift
//  LocationTracker
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "LocationTracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func add(location: LocationPublisher.Output) {
        let newLocation = Location(context: container.viewContext)
        let now = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        newLocation.timestamp = now
        newLocation.longitude = location.longitude
        newLocation.latitude = location.latitude
        newLocation.altitude = location.altitude
        newLocation.date = formatter.string(from: now)
        if (location.floor != nil) {
            newLocation.floor = location.floor!
        }
        newLocation.horizontalAccuracy = location.horizontalAccuracy
        newLocation.verticalAccuracy = location.verticalAccuracy
        
        save()
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Unable to save location.")
            }
        }
    }
}
