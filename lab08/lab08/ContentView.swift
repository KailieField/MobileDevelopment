import SwiftUI
import MapKit

struct ContentView: View {
    @State private var triangulationPoints: [MKPointAnnotation] = []
    @State private var route = false
    
    var body: some View {
        VStack {
            MapView(triangulationPoints: $triangulationPoints, route: $route)
                .edgesIgnoringSafeArea(.all)
            
            if triangulationPoints.count == 3 {
                Button(action: {
                    route.toggle()
                    
                }) {
                    
                    Text(route ? "Clear" : "Map Route")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                }
                .padding()
            }
        }
    }
}
