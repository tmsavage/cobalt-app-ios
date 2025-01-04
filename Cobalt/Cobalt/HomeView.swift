//
//  ContentView.swift
//  Cobalt
//
//  Created by Toby Savage on 11/22/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var filterSettings: FilterSettings
    @State private var restaurants: [Restaurant] = []
    @State private var searchQuery: String = ""
    @State private var navigateToResults: Bool = false
    @State private var selectedTab: BottomMenuBar.Tab = .list

    var body: some View {
        NavigationStack {
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
                    navigateToResults = true
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
                .navigationDestination(isPresented: $navigateToResults) {
                    ResultsView().environmentObject(filterSettings)
                }

                // Featured Bars
                Text("Featured Bars")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                Spacer()
            }
            .modifier(BottomMenuBar(selectedTab: $selectedTab)) // Attach BottomMenuBar
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(FilterSettings())
    }
}
