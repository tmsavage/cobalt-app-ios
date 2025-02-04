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
    let latitude: Double
    let longitude: Double
    let description: String
    let features: String
    let cobalt_apps: [HappyHour]

    var id: Int { restaurant_id }

    var fullAddress: String {
        "\(street_address), \(city), \(state) \(zip_code)"
    }

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
        case latitude
        case longitude
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
