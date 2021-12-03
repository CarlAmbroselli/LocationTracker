//
//  CLLocationCoordinate2D+Equatable.swift
//  LocationTracker
//

import Foundation
import MapKit

extension CLLocationCoordinate2D: Equatable {
    static public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
