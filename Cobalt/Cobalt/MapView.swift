//
//  MapView.swift
//  Cobalt
//
//  Created by Toby Savage on 1/4/25.
//

import SwiftUI

struct MapView: View {
    @Binding var selectedTab: BottomMenuBar.Tab

    var body: some View {
        VStack {
            // Logo at the top
            Text("Cobalt")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.blue)

            Spacer()
            Text("In Progress...")
                .foregroundColor(.gray)
            Spacer()
        }
        .withBottomMenuBar(selectedTab: $selectedTab) // Attach the consistent bottom menu bar
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(selectedTab: .constant(.map))
    }
}
