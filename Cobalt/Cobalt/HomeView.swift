//
//  HomeView.swift
//  Cobalt
//
//  Created by Toby Savage on 11/22/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var filterSettings: FilterSettings
    @Binding var selectedTab: BottomMenuBar.Tab // Updated to match new logic
    @State private var showResults: Bool = false // Track ResultsView visibility
    @State private var searchQuery: String = ""

    var body: some View {
        VStack {
            if showResults {
                // Navigate to ResultsView
                ResultsView(
                    searchQuery: searchQuery,
                    selectedTab: $selectedTab,
                    showResults: $showResults
                )
            } else {
                if selectedTab == .home { // Use .home instead of .list
                    VStack(spacing: 16) {
                        // Logo
                        Text("Spigo")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.orange)

                        // Search Bar (Styled to match ResultsView)
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass") // Search icon
                                    .foregroundColor(.gray)
                                Text("Search by bar...")
                                    .foregroundColor(.gray) // Same as ResultsView
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(Color(.systemGray6)) // Matches ResultsView background
                            .cornerRadius(8)
                        }
                        .contentShape(Rectangle()) // Make the entire area tappable
                        .onTapGesture {
                            selectedTab = .search // Navigate to Search tab without feedback
                        }
                        .padding(.horizontal)

                        // Featured Bars Section
                        Text("Featured Bars")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top)

                        Spacer()
                    }
                }
            }
        }
    }
}
