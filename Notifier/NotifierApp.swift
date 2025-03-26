//
//  NotifierApp.swift
//  Notifier
//
//  Created by sokhrym on 26.03.2025.
//

import SwiftUI

@main
struct NotifierApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("NotifierApp", image: "MenuBar") {
            ContentView()
                .environmentObject(appDelegate.appState)
        }
        .menuBarExtraStyle(.window)
    }
}
