//
//  StoryRow.swift
//  LocationTracker
//
//  Created by Carl on 11.11.21.
//

import Foundation

struct StoryRow: Hashable, Codable, Identifiable {
    var text: String
    
    var id: String {
        text
    }
}
