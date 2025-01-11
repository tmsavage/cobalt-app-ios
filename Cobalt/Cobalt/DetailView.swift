//
//  DetailView.swift
//  Cobalt
//
//  Created by Toby Savage on 11/24/24.
//

import SwiftUI

struct DetailView: View {
    let restaurant: Restaurant

    @Binding var selectedTab: BottomMenuBar.Tab // Bind the selected tab to manage navigation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Restaurant Details
                Text(restaurant.name)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
                Text(restaurant.location)
                    .font(.title3)
                    .foregroundColor(.secondary)

                Text(restaurant.description)
                    .font(.body)
                    .padding(.top, CGFloat.zero)

                Text("Features: \(restaurant.features)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)

                Divider()

                // Happy Hours Section
                Text("Happy Hours")
                    .font(.headline)
                    .padding(.vertical)

                ForEach(restaurant.cobalt_apps, id: \.specials) { hour in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(hour.day): \(hour.start_time) - \(hour.end_time)")
                            .font(.body)
                            .foregroundColor(.primary)
                        Text(hour.specials)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Details")
        .onChange(of: selectedTab) {
            if selectedTab == .search {
                // Perform any clean-up or state updates if needed here
                // Navigation logic will be managed by ResultsView
            }
        }

    }
}
