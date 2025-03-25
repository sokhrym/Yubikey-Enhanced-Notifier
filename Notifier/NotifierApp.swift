//
//  NotifierApp.swift
//  Notifier
//
//  Created by sokhrym on 25.03.2025.
//

import SwiftUI

@main
struct NotifierApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("NotifierApp", systemImage: "key") {
            ContentView()
                .environmentObject(appDelegate.appState)
                .id(appDelegate.appState.showModal)
        }
        .menuBarExtraStyle(.window)
    }
}
