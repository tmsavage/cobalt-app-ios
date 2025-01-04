//
//  FilterSettings.swift
//  Cobalt
//
//  Created by Toby Savage on 1/3/25.
//

import SwiftUI

class FilterSettings: ObservableObject {
    @Published var selectedDays: Set<String> = []
    @Published var startTime: String = "12 AM"
    @Published var endTime: String = "1 AM"
}
