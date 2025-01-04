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

    var body: some View {
        VStack {
            // Logo at the top
            Text("Cobalt")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.blue)

            // Results Header
            VStack(alignment: .leading) {
                Text("Results")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                Divider()
                    .background(Color.black)
                    .padding(.horizontal)
            }
            .padding(.top)

            // Results List
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
                        ForEach(filteredRestaurants) { restaurant in
                            NavigationLink(destination: DetailView(restaurant: restaurant)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(restaurant.name)
                                        .font(.headline)
                                        .foregroundColor(.black)

                                    Text(restaurant.location)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }

            // Bottom Navigation
            HStack {
                Button(action: {
                    // Navigate to list view
                }) {
                    VStack {
                        Image(systemName: "line.horizontal.3")
                        Text("List")
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity)

                Button(action: {
                    // Navigate to map view
                }) {
                    VStack {
                        Image(systemName: "mappin.circle")
                        Text("Map")
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
        }
        .onAppear {
            fetchRestaurants()
        }
    }

    // Fetch Restaurants from API
    func fetchRestaurants() {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "\(API.baseURL)/restaurants") else {
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

    
    func convertTimeStringToHours(_ time: String) -> Int {
        let formats = ["h:mm a", "h a"] // List of supported time formats
        let dateFormatter = DateFormatter()
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: time) {
                let calendar = Calendar.current
                return calendar.component(.hour, from: date)
            }
        }

        // If all formats fail, log an error and return 0
        print("Error converting time: \(time)")
        return 0
    }


    // Filtered Restaurants Based on Filters
    var filteredRestaurants: [Restaurant] {
        restaurants.filter { restaurant in
            // Check if any of the restaurant's happy hours match the selected days and time range
            restaurant.cobalt_apps.contains { happyHour in
                // Debug: Log happy hour data and filter settings
                print("Checking Happy Hour: \(happyHour.day) \(happyHour.start_time) - \(happyHour.end_time)")

                // Check if the day matches the user's selected days
                let matchesDay = filterSettings.selectedDays.isEmpty || filterSettings.selectedDays.contains(happyHour.day)

                // Convert times to numerical values for comparison
                let happyHourStart = convertTimeStringToHours(happyHour.start_time)
                let happyHourEnd = convertTimeStringToHours(happyHour.end_time)
                let userStart = convertTimeStringToHours(filterSettings.startTime)
                let userEnd = convertTimeStringToHours(filterSettings.endTime)

                // Check if the time ranges overlap
                let matchesTime = (userStart == 0 && userEnd == 23) || (userStart < happyHourEnd && userEnd > happyHourStart)

                // Debug: Log matching status
                print("Matches Day: \(matchesDay), Matches Time: \(matchesTime)")

                return matchesDay && matchesTime
            }
        }
    }

}

extension Restaurant {
    // Check if the restaurant is available during the selected time range
    func isAvailableDuring(start: String, end: String) -> Bool {
        guard let startTime = Int(start.split(separator: " ")[0]),
              let endTime = Int(end.split(separator: " ")[0]) else { return false }

        for happyHour in cobalt_apps {
            guard let hhStartTime = Int(happyHour.start_time.split(separator: ":")[0]),
                  let hhEndTime = Int(happyHour.end_time.split(separator: ":")[0]) else { continue }

            if hhStartTime <= startTime && hhEndTime >= endTime {
                return true
            }
        }
        return false
    }
}

