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
    @Binding var navigateToResults: Bool // Control navigation behavior

    var body: some View {
        VStack {
            // Logo
            Text("Cobalt")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.blue)

            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
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
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
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
                // Check if the day matches the user's selected days
                let matchesDay = filterSettings.selectedDays.isEmpty || filterSettings.selectedDays.contains(happyHour.day)

                // Convert times to numerical values for comparison
                let happyHourStart = convertTimeStringToHours(happyHour.start_time)
                let happyHourEnd = convertTimeStringToHours(happyHour.end_time)
                let userStart = convertTimeStringToHours(filterSettings.startTime)
                let userEnd = convertTimeStringToHours(filterSettings.endTime)

                // Check if the time ranges overlap
                let matchesTime = (userStart == 0 && userEnd == 23) || (userStart < happyHourEnd && userEnd > happyHourStart)

                return matchesDay && matchesTime
            }
        }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(navigateToResults: .constant(true))
            .environmentObject(FilterSettings())
    }
}
