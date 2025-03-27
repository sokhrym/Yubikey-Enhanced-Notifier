//
//  AppDelegate.swift
//  Notifier
//
//  Created by sokhrym on 26.03.2025.
//
import Cocoa
import SwiftUI
import Combine


class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate! = nil
    var appState = AppState()
    var floatingPanel: NSPanel?
    private var panelCloseTimer: Timer?
    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.instance = self
        appState.startMonitoring()
        
        appState.$notify
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notify in
                self?.handleNotificationStateChange(notify)
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
            let hostingController = NSHostingController(rootView: contentView)

            let panel = NSPanel(
                contentRect: NSRect(x: 720, y: 750, width: 270, height: 270),
                styleMask: [.borderless, .nonactivatingPanel, .utilityWindow],
                backing: .buffered,
                defer: true
            )

            panel.contentViewController = hostingController
            panel.level = .screenSaver
            panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            panel.isReleasedWhenClosed = false
            panel.isMovableByWindowBackground = false
            panel.hidesOnDeactivate = false


            self.floatingPanel = panel
            panel.makeKeyAndOrderFront(nil)
            
            self.startPanelCloseTimer()
        }
    }
    
    func closeFloatingPanel() {
        DispatchQueue.main.async {
            self.floatingPanel?.close()
            self.floatingPanel = nil
        }
        invalidatePanelCloseTimer()
    }

    private func handleNotificationStateChange(_ notify: Bool) {
        if notify {
            if appState.isSoundEnabled {
                playNotificationSound()
            }
            
            if appState.isModalEnabled {
                showFloatingPanel()
            }
        }
        else {
            closeFloatingPanel()
        }
    }

    private func playNotificationSound() {
        NSSound(named: "Funk")?.play()
    }
    
    private func startPanelCloseTimer() {
        invalidatePanelCloseTimer()

        panelCloseTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.closeFloatingPanel()
        }
    }

    private func invalidatePanelCloseTimer() {
        panelCloseTimer?.invalidate()
        panelCloseTimer = nil
    }
}
