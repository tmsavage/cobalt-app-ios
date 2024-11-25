//
//  ContentView.swift
//  Cobalt
//
//  Created by Toby Savage on 11/22/24.
//

import SwiftUI

struct HomeView: View {
    @State private var restaurants: [Restaurant] = []
    @State private var searchQuery: String = "" // For search bar
    @State private var selectedDay: String = "All" // For day filter

    let days = ["All", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Search restaurants...", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Day Filter Picker
                Picker("Day", selection: $selectedDay) {
                    ForEach(days, id: \.self) { day in
                        Text(day).tag(day)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Filtered and Searched List
                List(filteredRestaurants) { restaurant in
                    NavigationLink(destination: DetailView(restaurant: restaurant)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(restaurant.name)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text(restaurant.location)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1) // Limit to a single line if the location is long

                            Divider() // Add a line separator for better spacing
                        }
                        .padding(.vertical, 4) // Add vertical padding between list items
                    }
                }

                .listStyle(InsetGroupedListStyle()) // For better styling
                .navigationTitle("Happy Hour Spots")
                .onAppear {
                    fetchRestaurants()
                }
            }
        }
    }

    // Filter and Search Logic
    var filteredRestaurants: [Restaurant] {
        restaurants.filter { restaurant in
            (selectedDay == "All" || restaurant.cobalt_apps.contains { $0.day == selectedDay }) &&
            (searchQuery.isEmpty || restaurant.name.localizedCaseInsensitiveContains(searchQuery))
        }
    }

    // Fetch Data from Backend
    func fetchRestaurants() {
        guard let url = URL(string: "\(API.baseURL)/restaurants") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([Restaurant].self, from: data)
                    DispatchQueue.main.async {
                        self.restaurants = decodedData
                    }
                } catch {
                    print("Failed to decode: \(error)")
                }
            }
        }.resume()
    }
}
