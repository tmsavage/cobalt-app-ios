//
//  FilterView.swift
//  Cobalt
//
//  Created by Toby Savage on 1/3/25.
//

import SwiftUI

struct FilterView: View {
    @Environment(\.presentationMode) var presentationMode // Added for navigation dismissal
    @EnvironmentObject var filterSettings: FilterSettings // Access shared data
    @State private var selectedTab: BottomMenuBar.Tab = .list

    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let hours = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]

    var body: some View {
        VStack {
            // Logo at the top
            Text("Cobalt")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.blue)

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
                                ForEach(hours, id: \.self) { hour in
                                    Text(hour)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }

                        HStack {
                            Text("End:")
                                .font(.headline)
                            Spacer()
                            Picker("End Time", selection: $filterSettings.endTime) {
                                ForEach(hours, id: \.self) { hour in
                                    Text(hour)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                }
                .padding()
            }

            // Save Changes Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save Changes")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
        .modifier(BottomMenuBar(selectedTab: $selectedTab)) // Pass the binding
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
            .environmentObject(FilterSettings()) // Inject shared data for preview
    }
}
