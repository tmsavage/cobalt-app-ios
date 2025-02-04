//
//  BottomMenuBar.swift
//  Cobalt
//
//  Created by Toby Savage on 1/4/25.
//

import SwiftUI

struct BottomMenuBar: ViewModifier {
    @Binding var selectedTab: Tab

    enum Tab: String {
        case home
        case search
    }

    func body(content: Content) -> some View {
        VStack {
            content

            // Remove the divider
            // Divider()
            //     .background(Color.gray)

            HStack {
                // Home Tab
                Button(action: {
                    selectedTab = .home
                }) {
                    VStack {
                        Image(systemName: "house")
                            .foregroundColor(selectedTab == .home ? .orange : .gray)
                        Text("Home")
                            .font(.caption)
                            .foregroundColor(selectedTab == .home ? .orange : .gray)
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)

                // Search Tab
                Button(action: {
                    selectedTab = .search
                }) {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(selectedTab == .search ? .orange : .gray)
                        Text("Search")
                            .font(.caption)
                            .foregroundColor(selectedTab == .search ? .orange : .gray)
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8) // Reduce vertical padding to shorten the height
            .background(Color.orange.opacity(0.1))
        }
    }
}

extension View {
    func withBottomMenuBar(selectedTab: Binding<BottomMenuBar.Tab>) -> some View {
        self.modifier(BottomMenuBar(selectedTab: selectedTab))
    }
}
