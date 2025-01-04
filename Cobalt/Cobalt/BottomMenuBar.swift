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
        case list
        case map
    }

    func body(content: Content) -> some View {
        VStack {
            content

            Divider()
                .background(Color.gray)

            HStack {
                Button(action: {
                    selectedTab = .list
                }) {
                    VStack {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(selectedTab == .list ? .blue : .gray)
                        Text("List")
                            .font(.caption)
                            .foregroundColor(selectedTab == .list ? .blue : .gray)
                    }
                }
                .frame(maxWidth: .infinity)

                Button(action: {
                    selectedTab = .map
                }) {
                    VStack {
                        Image(systemName: "mappin.circle")
                            .foregroundColor(selectedTab == .map ? .blue : .gray)
                        Text("Map")
                            .font(.caption)
                            .foregroundColor(selectedTab == .map ? .blue : .gray)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
        }
    }
}

extension View {
    func withBottomMenuBar(selectedTab: Binding<BottomMenuBar.Tab>) -> some View {
        self.modifier(BottomMenuBar(selectedTab: selectedTab))
    }
}
