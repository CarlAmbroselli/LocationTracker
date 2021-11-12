//
//  ContentView.swift
//  LocationTracker
//

import CoreData
import Foundation
import MapKit
import SwiftUI

struct ContentView: View {
    
    var locations: SectionedFetchResults<String, Location>.Element
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.520008, longitude: 13.404954),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    var body: some View {
        VStack {
            map  
        }.preferredColorScheme(.dark)
        .edgesIgnoringSafeArea(.all)
    }
    
    private var map: some View {
        MapView(
              region: region,
              lineCoordinates: locations.map({ location in
                  CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
              })
            )
              .edgesIgnoringSafeArea(.all)
    }
}
