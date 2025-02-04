//
//  ResultsView.swift
//  Cobalt
//
//  Created by Toby Savage on 1/3/25.
//

import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var filterSettings: FilterSettings // Access filter settings
    @State private var restaurants: [Restaurant] = [] // Restaurants from API
    @State private var isLoading: Bool = true // Loading state
    @State private var errorMessage: String? = nil // Error handling
    @State private var locationQuery: String = "" // New: Location input

    @State var searchQuery: String
    @State private var isMapView: Bool = false // Track toggle state (List vs. Map)

    @Binding var selectedTab: BottomMenuBar.Tab
    @Binding var showResults: Bool

    var body: some View {
        VStack {
            // Top Navigation
            HStack {
                Button(action: {
                    selectedTab = .home // Explicitly switch to HomeView
                }) {
                    Text("Cancel")
                        .foregroundColor(.orange)
                }
                Spacer()

                // Map/List Toggle Button
                Button(action: {
                    isMapView.toggle()
                }) {
                    Text(isMapView ? "List View" : "Map View")
                        .fontWeight(.bold)
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }
            }
            .padding()

            // Search Bar
            TextField("Search by bar...", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.primary)
                .padding(.horizontal)

            // Location Bar
            TextField("Current Location", text: $locationQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.primary)
                .padding(.horizontal)

            // Filter, Start Time, and End Time Buttons
            HStack(spacing: 16) {
                // Filter Button
                NavigationLink(destination: FilterView().environmentObject(filterSettings)) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.vertical, 6)
                        .cornerRadius(8)
                        .foregroundColor(.orange)
                }

                // Start Time Display
                Text("Start: \(filterSettings.startTime)")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(25)

                // End Time Display
                Text("End: \(filterSettings.endTime)")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            .padding(.horizontal)

            Divider().padding(.vertical)

            // Results Header
//            Text("Results")
//                .font(.headline)
//                .padding(.horizontal, 16)
//                .frame(maxWidth: .infinity, alignment: .leading)

            // Conditionally display Map or List
            if isMapView {
                MapView(restaurants: restaurants)
            } else {
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(restaurants) { restaurant in
                                NavigationLink(
                                    destination: DetailView(
                                        restaurant: restaurant,
                                        selectedTab: $selectedTab
                                    )
                                ) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(restaurant.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text(restaurant.fullAddress) // Make sure Restaurant has a fullAddress property if needed
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .onAppear {
            fetchRestaurants()
        }
        .onChange(of: selectedTab) {
            if selectedTab == .search {
                isMapView = false // Reset to List View when returning to ResultsView
            }
        }
    }

    // Fetch Restaurants from API
    func fetchRestaurants() {
        isLoading = true
        errorMessage = nil

        // Construct the URL with query parameters.
        let baseURL = "\(API.baseURL)/cobalt_api_handler"
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = [
            URLQueryItem(name: "searchQuery", value: searchQuery),
            URLQueryItem(name: "locationQuery", value: locationQuery),
            URLQueryItem(name: "selectedDays", value: filterSettings.selectedDays.joined(separator: ",")),
            URLQueryItem(name: "startTime", value: filterSettings.startTime),
            URLQueryItem(name: "endTime", value: filterSettings.endTime)
        ]
        
        guard let url = urlComponents.url else {
            errorMessage = "Invalid API URL"
            isLoading = false
            return
        }

        NetworkingManager.fetch([Restaurant].self, from: url) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    restaurants = data
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    // Helper function to convert a time string to fractional hours
    func convertTimeStringToHours(_ time: String) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        guard let date = dateFormatter.date(from: time) else { return 0.0 }

        let calendar = Calendar.current
        let hours = Double(calendar.component(.hour, from: date))
        let minutes = Double(calendar.component(.minute, from: date)) / 60.0

        return hours + minutes
    }
}
