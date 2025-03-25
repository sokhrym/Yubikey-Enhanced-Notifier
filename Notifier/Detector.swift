//
//  Detector.swift
//  Notifier
//
//  Created by sokhrym on 25.03.2025.
//

import Foundation
import Combine

struct LogEntry: Decodable {
    let processImagePath: String
    let senderImagePath: String
    let subsystem: String
    let eventMessage: String
}

class TouchState {
    var fido2Needed = false
    var openPGPNeeded = false
    var lastNotify = Date()
    
    func checkToNotify() -> Bool? {
        let now = Date()
        guard now.timeIntervalSince(lastNotify) >= 0.1 else { return nil }
        
        let notifyNeeded = fido2Needed || openPGPNeeded
        
        lastNotify = now
        
        return notifyNeeded
    }
}

class Detector: ObservableObject {
    @Published var showModal = false {
        didSet {
            if showModal {
                print("showModal state changed to true")
            } else {
                print("showModal state changed to false")
            }
        }
    }
    private var touchState = TouchState()
    var appState: AppState
    
    init(appState: AppState)
    {
        self.appState = appState
    }

    func startMonitoring() {
        let process = Process()
        process.launchPath = "/usr/bin/log"
        process.arguments = ["stream", "--level", "debug", "--style", "ndjson"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        let handle = pipe.fileHandleForReading
        
        process.launch()
        
        let queue = DispatchQueue(label: "LogStreamQueue")
        
        queue.async {
            while let line = String(data: handle.availableData, encoding: .utf8), !line.isEmpty {
                guard let data = line.data(using: .utf8) else { continue }
                if let entry = try? JSONDecoder().decode(LogEntry.self, from: data) {
                    self.updateState(with: entry)
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.touchState.checkToNotify() != nil {
                DispatchQueue.main.async {
                    self.appState.showModal = self.touchState.fido2Needed || self.touchState.openPGPNeeded
                }
            }
        }
    }
    
    func stopMonitoring() {
        
    }
    
    private func updateState(with entry: LogEntry) {
        if entry.processImagePath == "/kernel" && entry.senderImagePath.hasSuffix("IOHIDFamily") {
            touchState.fido2Needed = entry.eventMessage.contains("IOHIDLibUserClient:0x") && entry.eventMessage.hasSuffix("startQueue")
        }
        
        if entry.processImagePath.hasSuffix("usbsmartcardreaderd") && entry.subsystem.hasSuffix("CryptoTokenKit") {
            touchState.openPGPNeeded = entry.eventMessage == "Time extension received"
        }
    }
}
