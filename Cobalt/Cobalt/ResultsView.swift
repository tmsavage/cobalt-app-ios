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
    @Binding var selectedTab: BottomMenuBar.Tab // Track tab selection
    @Binding var showResults: Bool // Control visibility of ResultsView

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
                        ForEach(restaurants) { restaurant in
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
        .onAppear {
            fetchRestaurants()
        }
        .onChange(of: selectedTab) { newTab in
            // React to bottom menu tab changes
            if newTab == .map {
                // Transition to MapView
                showResults = false
            }
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
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(selectedTab: .constant(.list), showResults: .constant(true))
            .environmentObject(FilterSettings())
    }
}
