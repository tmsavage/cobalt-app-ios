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
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                HomeView()
                    .environmentObject(filterSettings) // Pass to HomeView
            }
        }
    }
}
