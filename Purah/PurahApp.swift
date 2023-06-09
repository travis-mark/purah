//  Purah - PurahApp.swift
//  Created by Travis Luckenbaugh on 5/30/23.

import SwiftUI

func showError(_ error: Error) {
    // TODO: Publish error
    NSLog(error.localizedDescription)
}

func bundleName() -> String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Purah"
}

@main struct PurahApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
