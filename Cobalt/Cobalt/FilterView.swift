//
//  FilterView.swift
//  Cobalt
//
//  Created by Toby Savage on 1/3/25.
//

import SwiftUI

struct FilterView: View {
    @Environment(\.presentationMode) var presentationMode // For dismissing the view
    @EnvironmentObject var filterSettings: FilterSettings // Access shared data

    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    private var halfHourIncrements: [String] {
        var times = [String]()
        // Loop from hour 0 to 23
        for hour in 0..<24 {
            // Loop over two half-hour increments (xx:00 and xx:30)
            for half in 0..<2 {
                let minute = half * 30
                let isAM = hour < 12
                let twelveHour = hour % 12
                let displayHour = (twelveHour == 0 ? 12 : twelveHour)  // 0 -> 12, 13 -> 1, etc.
                
                // Convert 0 or 30 into a zero-padded string ("00" or "30")
                let displayMinute = String(format: "%02d", minute)
                
                let meridiem = isAM ? "AM" : "PM"
                let timeString = "\(displayHour):\(displayMinute) \(meridiem)"
                times.append(timeString)
            }
        }
        return times
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top row: Logo on the left, Clear All button on the right
            HStack {

                Spacer()
                
                Button(action: {
                    // Clear all filters
                    filterSettings.selectedDays.removeAll()
                    filterSettings.startTime = "12:00 AM"
                    filterSettings.endTime   = "11:30 PM"
                }) {
                    Text("Clear All")
                        .foregroundColor(.orange)
                }
                .padding(.trailing)
            }
            .padding(.top) // Some top padding to space from the top edge

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Day Selection
                    VStack(alignment: .leading) {
                        Text("Day")
                            .font(.title2)
                            .fontWeight(.bold)

                        Divider()
                            .background(Color.black)

                        ForEach(days, id: \.self) { day in
                            HStack {
                                Button(action: {
                                    if filterSettings.selectedDays.contains(day) {
                                        filterSettings.selectedDays.remove(day)
                                    } else {
                                        filterSettings.selectedDays.insert(day)
                                    }
                                }) {
                                    Image(systemName: filterSettings.selectedDays.contains(day) ? "checkmark.square" : "square")
                                        .foregroundColor(.orange)
                                }
                                Text(day)
                                    .foregroundColor(.primary)
                            }
                        }
                    }

                    // Time Selection
                    VStack(alignment: .leading) {
                        Text("Time")
                            .font(.title2)
                            .fontWeight(.bold)

                        Divider()
                            .background(Color.black)

                        HStack {
                            Text("Start:")
                                .font(.headline)
                            Spacer()
                            
                            Picker("Start Time", selection: $filterSettings.startTime) {
                                ForEach(halfHourIncrements, id: \.self) { time in
                                    Text(time)
                                        .foregroundColor(.primary)
                                        .tag(time)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 120, height: 150)
                        }
                                
                        HStack {
                            Text("End:")
                                .font(.headline)
                            Spacer()
                            
                            Picker("End Time", selection: $filterSettings.endTime) {
                                ForEach(halfHourIncrements, id: \.self) { time in
                                    Text(time)
                                        .foregroundColor(.primary)
                                        .tag(time)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 120, height: 150)
                        }
                    }
                }
                .padding()
            }

            // Apply Button at the bottom
            Button(action: {
                presentationMode.wrappedValue.dismiss() // Dismiss the FilterView
            }) {
                Text("Apply")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .padding(.bottom) // Bottom padding
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
            .environmentObject(FilterSettings()) // Inject shared data for preview
    }
}
