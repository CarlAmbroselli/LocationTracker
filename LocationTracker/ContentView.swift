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
    
    @State private var shownLocations: [Location] = [];
    
    var body: some View {
        VStack {
            list
            actions
            map  
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var list: some View {
        List(locations.reversed()) { location in
            VStack {
                Text((location.timestamp?.formatted() ?? "no timestamp") + ": \(String(format: "%.5f", location.latitude)) , \(String(format: "%.5f", location.longitude))")
            }
            .frame(maxWidth: .infinity)
            .padding(5)
            .onTapGesture {
                if shownLocations.contains(location) {
                    shownLocations = shownLocations.filter{$0 != location}
                } else {
                    shownLocations.append(location)
                }
                region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            }.background(shownLocations.contains(location) ? Color.brown : Color.black).preferredColorScheme(ColorScheme.dark)
        }.listStyle(PlainListStyle())
    }
    
    private var actions: some View {
        HStack {
            Spacer()
            Button(action: {
                shownLocations = locations.reversed().dropLast(locations.count > 50 ? locations.count - 50 : 0)
            }) {
                Text("Show 50")
            }.padding(10)
            Spacer()
            Button(action: {
                shownLocations = locations.reversed().filter({ location in
                    guard let timestamp = location.timestamp else { return false }
                    return timestamp > Date.now.addingTimeInterval(-TimeInterval(60 * 60 * 24 * 2))
                })
            }) {
                Text("Last 48h")
            }.padding(10)
            Spacer()
            Button(action: {
                shownLocations = []
            }) {
                Text("Hide all")
            }.padding(10)
            Spacer()
        }
    }
    
    private var map: some View {
        Map(coordinateRegion: $region,
            interactionModes: .all,
            showsUserLocation: false,
            userTrackingMode: .none,
            annotationItems: shownLocations) { location in
            
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                Circle().fill(Color.blue).frame(width: 10, height: 10)
            }
        }
    }
}
