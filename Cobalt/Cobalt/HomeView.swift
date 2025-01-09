//
//  HomeView.swift
//  Cobalt
//
//  Created by Toby Savage on 11/22/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var filterSettings: FilterSettings
    @State private var selectedTab: BottomMenuBar.Tab = .list
    @State private var showResults: Bool = false // Track ResultsView visibility
    @State private var searchQuery: String = ""

    var body: some View {
        VStack {
            if showResults {
                // Pass the search text into ResultsView
                ResultsView(
                    searchQuery: searchQuery,
                    selectedTab: $selectedTab,
                    showResults: $showResults
                )
            } else {
                if selectedTab == .list {
                    VStack {
                        // Logo
                        Text("Cobalt")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.blue)

                        // Search Bar
                        HStack {
                            TextField("Search by bar..", text: $searchQuery)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading)

                            NavigationLink(destination: FilterView().environmentObject(filterSettings)) {
                                Image(systemName: "line.horizontal.3.decrease.circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .padding(.trailing)
                            }
                        }
                        .padding()

                        // Search Button
                        Button(action: {
                            // Show ResultsView, which will use searchQuery
                            showResults = true
                        }) {
                            Text("Search")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
        
                        // Featured Bars
                        Text("Featured Bars")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top)

                        Spacer()
                    }
                } else if selectedTab == .map {
                    MapView(selectedTab: $selectedTab)
                }
            }
        }
        .modifier(BottomMenuBar(selectedTab: $selectedTab)) // Attach consistent menu bar
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(FilterSettings())
    }
}
