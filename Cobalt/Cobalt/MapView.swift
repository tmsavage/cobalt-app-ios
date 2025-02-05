import SwiftUI
import MapKit
import CoreLocation

/// High-level SwiftUI View that displays a map + user location + triggers DetailView on pin tap.
struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    let restaurants: [Restaurant]
    
    // Add a closure to notify the parent which restaurant was tapped
    let didSelectRestaurant: (Restaurant) -> Void
    
    var body: some View {
        MapViewRepresentable(
            locationManager: locationManager,
            restaurants: restaurants
        ) { tappedRestaurant in
            didSelectRestaurant(tappedRestaurant)
        }
    }
}



/// The UIViewRepresentable that wraps MKMapView
struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    let restaurants: [Restaurant]
    
    // Add a callback closure to notify SwiftUI when an annotation is tapped.
    let onAnnotationTap: (Restaurant) -> Void

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

        // 2) Compare count vs new restaurant list
        if existingAnnotations.count != restaurants.count {
            // Remove old
            mapView.removeAnnotations(existingAnnotations)
            
            // Add new
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

        // 3) Only center once
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
            // Keep using the default user-location “blue dot”
            guard !(annotation is MKUserLocation) else {
                return nil
            }
            
            let identifier = "RestaurantMarker"
            
            // Try to reuse an existing marker view, otherwise create a new one
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            // Always update the annotation reference
            annotationView.annotation = annotation
            
            // Let the callout (bubble) show when tapped
            annotationView.canShowCallout = true
            
            // Always set your glyph + color styling here
            annotationView.glyphText = "🍸"
            annotationView.markerTintColor = .orange
            
            return annotationView
        }

        
        /// Called when the user taps on an annotation’s view (pin).
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MKPointAnnotation else { return }
            // find the matching Restaurant...
            if let tappedRestaurant = parent.restaurants.first(where: {
                $0.latitude == annotation.coordinate.latitude &&
                $0.longitude == annotation.coordinate.longitude
            }) {
                parent.onAnnotationTap(tappedRestaurant)
            }
        }
    }
}



// MARK: - Preview
//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        // A dummy list of restaurants for quick testing
//        MapView(restaurants: [
//            Restaurant(
//                restaurant_id: 1,
//                name: "The Local Bar",
//                street_address: "123 Main St",
//                city: "Cityville",
//                state: "NJ",
//                zip_code: "07704",
//                latitude: 40.7112,
//                longitude: -74.0093,
//                description: "A cozy bar with great drinks.",
//                features: "Live music, outdoor seating",
//                cobalt_apps: []
//            ),
//            Restaurant(
//                restaurant_id: 2,
//                name: "Happy Hour Central",
//                street_address: "456 Elm St",
//                city: "Townsville",
//                state: "NJ",
//                zip_code: "08012",
//                latitude: 40.7178,
//                longitude: -74.0036,
//                description: "Best happy hour deals in town.",
//                features: "Sports TV, late hours",
//                cobalt_apps: []
//            )
//        ])
//    }
//}
