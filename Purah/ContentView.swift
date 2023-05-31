//
//  ContentView.swift
//  Purah
//
//  Created by Travis Luckenbaugh on 5/30/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("Tab 1")
                .tabItem {
                    Image(systemName: "person.2")
                    Text("People")
                }
            Text("Tab 2")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Today")
                }
            Text("Tab 3")
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            Text("Tab 4")
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Photos")
                }
            Text("Tab 5")
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
