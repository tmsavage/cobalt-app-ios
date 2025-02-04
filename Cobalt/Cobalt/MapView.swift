import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let restaurants: [Restaurant] // Restaurants filtered from search results

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(parent: MapView) {
            self.parent = parent
        }

        // Custom annotation view for user location
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Check if this is the user's location
            if annotation is MKUserLocation {
                let identifier = "UserLocation"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

                if annotationView == nil {
                    annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = false

                    // Add custom ZStack for user location pin
                    annotationView?.image = UIImage(systemName: "circle.fill") // Placeholder; customize as needed
                    annotationView?.frame.size = CGSize(width: 32, height: 32)

                    let userLocationView = ZStack {
                        Circle()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.blue.opacity(0.25))

                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)

                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.blue)
                    }

                    // Convert ZStack to UIImage (optional, or use directly)
                    annotationView?.image = UIImage(view: userLocationView)
                }
                return annotationView
            }

            return nil
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove existing annotations
        mapView.removeAnnotations(mapView.annotations)

        // Add annotations for filtered restaurants
        let annotations = restaurants.map { restaurant -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.title = restaurant.name
            annotation.subtitle = restaurant.fullAddress
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: restaurant.latitude,
                longitude: restaurant.longitude
            )
            return annotation
        }
        mapView.addAnnotations(annotations)

        // Zoom to fit all pins if any are present
        if !annotations.isEmpty {
            let region = MKCoordinateRegion(
                center: annotations.first!.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            mapView.setRegion(region, animated: true)
        }
    }
}

// Helper to convert a SwiftUI view to UIImage
extension UIImage {
    convenience init<V: View>(view: V) {
        let controller = UIHostingController(rootView: view)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let image = renderer.image { context in
            view?.layer.render(in: context.cgContext)
        }
        self.init(cgImage: image.cgImage!)
    }
}

// For Preview
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
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
