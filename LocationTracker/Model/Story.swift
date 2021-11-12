//
//  Story.swift
//  LocationTracker
//
//  Created by Carl on 11.11.21.
//

import Foundation

struct Story: Hashable, Codable, Identifiable {
    var longitude: Double
    var latitude: Double
    var timestamp: Date
    
    var id: String {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: timestamp)
        return "\(timestamp)\(longitude)\(latitude)"
    }
    
}
