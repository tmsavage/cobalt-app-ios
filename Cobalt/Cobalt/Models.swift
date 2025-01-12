//
//  Models.swift
//  Cobalt
//
//  Created by Toby Savage on 11/24/24.
//

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
    let street_address: String
    let city: String
    let state: String
    let zip_code: String
    let description: String
    let features: String
    let cobalt_apps: [HappyHour] // Match the key in the JSON response

    var id: Int { restaurant_id }

    // Add a computed property for the full address
    var fullAddress: String {
        "\(street_address), \(city), \(state) \(zip_code)"
    }

    // Add a computed property or array for associated days
    var days: [String] {
        cobalt_apps.map { $0.day }
    }

    enum CodingKeys: String, CodingKey {
        case restaurant_id
        case name
        case street_address
        case city
        case state
        case zip_code
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
