//
//  ContentView.swift
//  LocationTracker
//

import CoreData
import Foundation
import MapKit
import SwiftUI

struct MapContentView: View {
    
    var locations: SectionedFetchResults<String, Location>.Element
    
    var body: some View {
        VStack {
            map  
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var map: some View {
        MapView(
              lineCoordinates: locations.map({ location in
                  CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
              })
            )
    }
}
