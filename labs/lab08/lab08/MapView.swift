import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    @Binding var triangulationPoints: [MKPointAnnotation]
    @Binding var route: Bool
    
    let mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        
        // Zoom to Ontario
        let ontarioCenter = CLLocationCoordinate2D(latitude: 50.0, longitude: -85.0)
        let region = MKCoordinateRegion(center: ontarioCenter, latitudinalMeters: 1000000, longitudinalMeters: 1000000)
        mapView.setRegion(region, animated: false)
        
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(gesture)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        context.coordinator.updateMap()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var routeOverlays: [MKOverlay] = []
        var distanceLabels: [MKPointAnnotation] = []
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: parent.mapView)
            let coordinate = parent.mapView.convert(location, toCoordinateFrom: parent.mapView)
            
            if let index = parent.triangulationPoints.firstIndex(where: {
                CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
                    .distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) < 500
            }) {
                parent.mapView.removeAnnotation(parent.triangulationPoints[index])
                parent.triangulationPoints.remove(at: index)
            } else if parent.triangulationPoints.count < 3 {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                parent.triangulationPoints.append(annotation)
                parent.mapView.addAnnotation(annotation)
                
                getCityName(for: coordinate) { city in
                    DispatchQueue.main.async {
                        annotation.title = city ?? "Unknown City"
                    }
                }
            }
            
            updateMap()
        }
        
        func updateMap() {
            parent.mapView.removeOverlays(parent.mapView.overlays)
            parent.mapView.removeAnnotations(distanceLabels)
            distanceLabels.removeAll()
            routeOverlays.removeAll()
            
            guard parent.triangulationPoints.count == 3 else { return }
            
            let coords = parent.triangulationPoints.map { $0.coordinate }
            
            for i in 0..<3 {
                let start = coords[i]
                let end = coords[(i + 1) % 3]
                
                let polyline = MKPolyline(coordinates: [start, end], count: 2)
                parent.mapView.addOverlay(polyline)
                
                let distance = CLLocation(latitude: start.latitude, longitude: start.longitude)
                    .distance(from: CLLocation(latitude: end.latitude, longitude: end.longitude)) / 1000
                let label = MKPointAnnotation()
                label.coordinate = CLLocationCoordinate2D(
                    latitude: (start.latitude + end.latitude) / 2,
                    longitude: (start.longitude + end.longitude) / 2)
                label.title = String(format: "%.1f km", distance)
                distanceLabels.append(label)
                parent.mapView.addAnnotation(label)
            }
            
            let polygon = MKPolygon(coordinates: coords, count: 3)
            parent.mapView.addOverlay(polygon)
            
            if parent.route {
                getRoute(from: parent.triangulationPoints)
            }
        }

        func getRoute(from annotations: [MKAnnotation]) {
            guard annotations.count == 3 else {
                print("⚠️ 3 points required for route.")
                return
            }
            
            let coords = annotations.map { $0.coordinate }
            let routePoints = coords + [coords[0]]
            
            for i in 0..<routePoints.count - 1 {
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: routePoints[i]))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: routePoints[i + 1]))
                request.transportType = .automobile
                
                let directions = MKDirections(request: request)
                directions.calculate { response, error in
                    if let error = error {
                        print("❌ Route error: \(error.localizedDescription)")
                        return
                    }
                    
                    if let route = response?.routes.first {
                        DispatchQueue.main.async {
                            self.routeOverlays.append(route.polyline)
                            self.parent.mapView.addOverlay(route.polyline)
                            print("✅ Route added.")
                        }
                    } else {
                        print("⚠️ No route found.")
                    }
                }
            }
        }
        
        func getCityName(for coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                if let city = placemarks?.first?.locality {
                    completion(city)
                } else {
                    completion(nil)
                }
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                if routeOverlays.contains(where: { $0 === overlay }) {
                    renderer.strokeColor = .blue
                    renderer.lineWidth = 5
                } else {
                    renderer.strokeColor = .green
                    renderer.lineWidth = 3
                }
                return renderer
            }
            
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor.red.withAlphaComponent(0.3)
                return renderer
            }
            
            return MKOverlayRenderer()
        }
    }
}
