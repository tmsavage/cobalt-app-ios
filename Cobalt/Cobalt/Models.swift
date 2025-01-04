//
//  Models.swift
//  Cobalt
//
//  Created by Toby Savage on 11/24/24.
//

import Foundation

struct Restaurant: Identifiable, Decodable {
    let restaurant_id: Int
    let name: String
    let location: String
    let description: String
    let features: String
    let cobalt_apps: [HappyHour] // Match the key in the JSON response

    var id: Int { restaurant_id }

    // Add a computed property or array for associated days
    var days: [String] {
        cobalt_apps.map { $0.day }
    }

    enum CodingKeys: String, CodingKey {
        case restaurant_id
        case name
        case location
        case description
        case features
        case cobalt_apps
    }
}

struct HappyHour: Decodable {
    let day: String
    let start_time: String
    let end_time: String
    let specials: String
}

