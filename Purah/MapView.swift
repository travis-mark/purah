//  Purah - MapView.swift
//  Created by Travis Luckenbaugh on 6/3/23.

import SwiftUI
import MapKit

// TODO: Current location
// TODO: (???) Orientation / rotation
// TODO: Weather sub view
// TODO: Event / Reminder / Address book integration
struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334722, longitude: -122.008889),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        Map(coordinateRegion: $region)
    }
}

