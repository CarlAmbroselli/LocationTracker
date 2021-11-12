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
        return "\(timestamp)\(longitude)\(latitude)"
    }
    
}
