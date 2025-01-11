//
//  MapView.swift
//  Cobalt
//
//  Created by Toby Savage on 1/4/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    let restaurants: [Restaurant] // Accept a list of restaurants to display pins

    var body: some View {
        VStack {

            Spacer()

            // Placeholder Map
            Text("Map with \(restaurants.count) Pins")
                .foregroundColor(.gray)
                .font(.headline)

            Spacer()
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(restaurants: []) // Pass an empty array for preview
    }
}
