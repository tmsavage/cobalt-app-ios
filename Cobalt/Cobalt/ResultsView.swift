import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var filterSettings: FilterSettings
    @State private var restaurants: [Restaurant] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var locationQuery: String = ""

    @State var searchQuery: String
    @State private var isMapView: Bool = false

    @Binding var selectedTab: BottomMenuBar.Tab
    @Binding var showResults: Bool
    
    /// Add these two properties to handle pin-tap navigation
    @State private var selectedRestaurant: Restaurant? = nil
    @State private var showDetail: Bool = false

    var body: some View {
        // Wrap everything in ONE NavigationStack, so tapping a pin
        // will push the detail screen above all filter UI.
        NavigationStack {
            VStack {
                // MARK: - Top Navigation
                HStack {
                    Button(action: {
                        selectedTab = .home
                    }) {
                        Text("Cancel")
                            .foregroundColor(.orange)
                    }
                    Spacer()

                    // Map/List Toggle Button
                    Button(action: {
                        isMapView.toggle()
                    }) {
                        Text(isMapView ? "List View" : "Map View")
                            .fontWeight(.bold)
                            .padding(8)
                            .background(Color.orange.opacity(0.1))
                            .foregroundColor(.orange)
                            .cornerRadius(8)
                    }
                }
                .padding()

                // MARK: - Search Bars
                TextField("Search by bar...", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.primary)
                    .padding(.horizontal)

                TextField("Current Location", text: $locationQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.primary)
                    .padding(.horizontal)

                // MARK: - Filter, Start Time, End Time
                HStack(spacing: 16) {
                    NavigationLink(destination: FilterView().environmentObject(filterSettings)) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.vertical, 6)
                            .cornerRadius(8)
                            .foregroundColor(.orange)
                    }
                    Text("Start: \(filterSettings.startTime)")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(25)

                    Text("End: \(filterSettings.endTime)")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding(.horizontal)

                Divider().padding(.vertical)
                
                // MARK: - Results
                if isMapView {
                    // Show the Map. Pass a closure so we know which pin was tapped.
                    MapView(restaurants: restaurants) { tapped in
                        selectedRestaurant = tapped
                        showDetail = true
                    }
                } else {
                    // Show the list
                    if isLoading {
                        ProgressView("Loading...")
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(restaurants) { restaurant in
                                    NavigationLink(
                                        destination: DetailView(
                                            restaurant: restaurant,
                                            selectedTab: $selectedTab
                                        )
                                    ) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(restaurant.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text(restaurant.fullAddress)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .onAppear {
                fetchRestaurants()
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue == .search {
                    isMapView = false
                }
            }
            // When `showDetail` is true, we navigate to the detail for the selected Restaurant
            .navigationDestination(isPresented: $showDetail) {
                if let r = selectedRestaurant {
                    DetailView(
                        restaurant: r,
                        selectedTab: $selectedTab
                    )
                } else {
                    // Fallback, never shown
                    EmptyView()
                }
            }
        } // NavigationStack
    }

    // MARK: - Networking
    func fetchRestaurants() {
        isLoading = true
        errorMessage = nil

        let baseURL = "\(API.baseURL)/cobalt_api_handler"
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = [
            URLQueryItem(name: "searchQuery", value: searchQuery),
            URLQueryItem(name: "locationQuery", value: locationQuery),
            URLQueryItem(name: "selectedDays", value: filterSettings.selectedDays.joined(separator: ",")),
            URLQueryItem(name: "startTime", value: filterSettings.startTime),
            URLQueryItem(name: "endTime", value: filterSettings.endTime)
        ]
        
        guard let url = urlComponents.url else {
            errorMessage = "Invalid API URL"
            isLoading = false
            return
        }

        NetworkingManager.fetch([Restaurant].self, from: url) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    restaurants = data
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
