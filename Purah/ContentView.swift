//  Purah - ContentView.swift
//  Created by Travis Luckenbaugh on 5/30/23.

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PeopleView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("People")
                }
            TodayView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Today")
                }
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            PhotosView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Photos")
                }
            VitalsView()
                .tabItem {
                    Image(systemName: "waveform.path.ecg.rectangle")
                    Text("Vitals")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
