//
//  CobaltApp.swift
//  Cobalt
//
//  Created by Toby Savage on 11/22/24.
//

import SwiftUI

@main
struct CobaltApp: App {
    @StateObject var filterSettings = FilterSettings() // Shared Instance
    @State private var selectedTab: BottomMenuBar.Tab = .home // Track selected tab

    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    if selectedTab == .home {
                        HomeView(selectedTab: $selectedTab) // Pass the binding to HomeView
                            .environmentObject(filterSettings)
                            .withBottomMenuBar(selectedTab: $selectedTab) // Apply the BottomMenuBar
                    } else if selectedTab == .search {
                        ResultsView(
                            searchQuery: "", // Pass an empty query initially
                            selectedTab: $selectedTab,
                            showResults: .constant(true) // Always show results in the Search tab
                        )
                        .environmentObject(filterSettings)
                        .withBottomMenuBar(selectedTab: $selectedTab) // Apply the BottomMenuBar
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle()) // Ensure proper navigation stack behavior
        }
    }
}
