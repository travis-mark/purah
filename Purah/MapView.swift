//  Purah - MapView.swift
//  Created by Travis Luckenbaugh on 6/3/23.

import SwiftUI
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Binding var currentLocation: CLLocationCoordinate2D
    
    init(currentLocation: Binding<CLLocationCoordinate2D>) {
        _currentLocation = currentLocation
    }
    
    func readOnce() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
        }
        locationManager.stopUpdatingLocation()
    }
}

// TODO: (???) Orientation / rotation
struct MapView: View {
    
    @State private var locationManager: LocationManager?
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    var body: some View {
        Map(coordinateRegion: $region)
            .onAppear {
                if (locationManager == nil) {
                    locationManager = LocationManager(currentLocation: $region.center)
                }
                locationManager?.readOnce()
            }
    }
}

