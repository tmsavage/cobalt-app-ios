import SwiftUI
import MapKit
import CoreLocation

/// High-level SwiftUI View that simply displays a map + user location.
struct MapView: View {
    /// Each MapView will manage its own instance of LocationManager.
    @StateObject private var locationManager = LocationManager()
    
    let restaurants: [Restaurant]
    
    var body: some View {
        MapViewRepresentable(
            locationManager: locationManager,
            restaurants: restaurants
        )
    }
}

/// The UIViewRepresentable that wraps MKMapView
struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    let restaurants: [Restaurant]

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // 1) Collect all existing non-user annotations
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }

        // 2) Compare them to the new list. In a real app, you might compare IDs or do a deeper check.
        //    Here, we’ll do a quick check by coordinate count. If they match exactly, no need to remove/re-add.
        if existingAnnotations.count != restaurants.count {
            // Remove previous (non-user) annotations
            mapView.removeAnnotations(existingAnnotations)
            
            // Add restaurant annotations
            let newAnnotations = restaurants.map { restaurant -> MKPointAnnotation in
                let annotation = MKPointAnnotation()
                annotation.title = restaurant.name
                annotation.subtitle = restaurant.fullAddress
                annotation.coordinate = CLLocationCoordinate2D(
                    latitude: restaurant.latitude,
                    longitude: restaurant.longitude
                )
                return annotation
            }
            mapView.addAnnotations(newAnnotations)
        }

        // 3) Keep your original “center once” logic unchanged
        if !context.coordinator.hasSetInitialRegion {
            if let userLocation = locationManager.currentLocation {
                let region = MKCoordinateRegion(
                    center: userLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                mapView.setRegion(region, animated: true)
                
                context.coordinator.hasSetInitialRegion = true
            }
        }
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        var hasSetInitialRegion = false
        let parent: MapViewRepresentable
        
        init(parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil // Default blue-dot for user location
            }
            // For restaurants, return nil for default pins (or customize if you like).
            return nil
        }
    }
}


// MARK: - Preview
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        // A dummy list of restaurants for quick testing
        MapView(restaurants: [
            Restaurant(
                restaurant_id: 1,
                name: "The Local Bar",
                street_address: "123 Main St",
                city: "Cityville",
                state: "NJ",
                zip_code: "07704",
                latitude: 40.7112,
                longitude: -74.0093,
                description: "A cozy bar with great drinks.",
                features: "Live music, outdoor seating",
                cobalt_apps: []
            ),
            Restaurant(
                restaurant_id: 2,
                name: "Happy Hour Central",
                street_address: "456 Elm St",
                city: "Townsville",
                state: "NJ",
                zip_code: "08012",
                latitude: 40.7178,
                longitude: -74.0036,
                description: "Best happy hour deals in town.",
                features: "Sports TV, late hours",
                cobalt_apps: []
            )
        ])
    }
}
