//
//  LocationPublisher.swift
//  LocationTracker
//

import Combine
import CoreLocation
import Foundation

class LocationPublisher: NSObject {
    
    typealias Output = (longitude: Double, latitude: Double, altitude: Double, floor: Int16?, horizontalAccuracy: Double, verticalAccuracy: Double)
    typealias Failure = Never
    
    private let wrapped = PassthroughSubject<(Output), Failure>()
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.startMonitoringSignificantLocationChanges()
        
        self.locationManager.startUpdatingLocation()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.distanceFilter = 20
    }
}

extension LocationPublisher: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Swift.print("Locations received", locations)
        locations.forEach { location in
            var floor: Int16?
            if (location.floor != nil) {
                floor = Int16(location.floor!.level)
            }
            wrapped.send((
                longitude: location.coordinate.longitude,
                latitude: location.coordinate.latitude,
                altitude: location.altitude,
                floor: floor,
                horizontalAccuracy: location.horizontalAccuracy,
                verticalAccuracy: location.verticalAccuracy))
        }
    }
}

extension LocationPublisher: Publisher {
    func receive<Downstream: Subscriber>(subscriber: Downstream) where Failure == Downstream.Failure, Output == Downstream.Input {
        wrapped.subscribe(subscriber)
    }
}
