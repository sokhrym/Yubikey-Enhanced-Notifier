//
//  AppDelegate.swift
//  Notifier
//
//  Created by sokhrym on 25.03.2025.
//
import Cocoa
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate! = nil
    var appState = AppState()
    var floatingPanel: NSPanel?
    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.instance = self
        appState.startMonitoring()
        
        appState.$showModal
            .receive(on: DispatchQueue.main)
            .sink { show in
                if show {
                    
                    self.showFloatingPanel()
                } else {
                    self.closeFloatingPanel()
                }
            }
            .store(in: &cancellables)
    }

    func applicationWillTerminate(_ notification: Notification) {
        appState.stopMonitoring()
        cancellables.forEach { $0.cancel() }
    }

    func showFloatingPanel() {
        guard floatingPanel == nil else {
            print("Floating panel already exists.")
            return
        }

        DispatchQueue.main.async {
            let contentView = YubiKeyPromptView()
                .environmentObject(self.appState)
            let hostingController = NSHostingController(rootView: contentView)

            self.floatingPanel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: true
            )

            self.floatingPanel?.contentViewController = hostingController
            self.floatingPanel?.center()
            self.floatingPanel?.level = .floating
            self.floatingPanel?.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            self.floatingPanel?.isReleasedWhenClosed = false
            self.floatingPanel?.isMovableByWindowBackground = true
            self.floatingPanel?.hidesOnDeactivate = false
            self.floatingPanel?.makeKeyAndOrderFront(nil)
        }
    }

    func closeFloatingPanel() {
        DispatchQueue.main.async {
            self.floatingPanel?.close()
            self.floatingPanel = nil
        }
    }
}
