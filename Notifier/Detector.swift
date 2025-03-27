//
//  Detector.swift
//  Notifier
//
//  Created by sokhrym on 26.03.2025.
//
import Combine
import Foundation

struct LogEntry: Decodable {
    let processImagePath: String
    let senderImagePath: String
    let subsystem: String
    let eventMessage: String
}

class TouchState {
    var fido2Needed = false
    var openPGPNeeded = false

    func checkToNotify() -> Bool {
        let notifyNeeded = fido2Needed || openPGPNeeded

        return notifyNeeded
    }
}

class Detector: ObservableObject {
    private var touchState = TouchState()
    var appState: AppState

    private var isModalVisible = false
    private var modalTimer: Timer?

    private var process: Process!
    private var pipe: Pipe!
    private var handle: FileHandle!

    private var source: DispatchSourceRead!

    init(appState: AppState) {
        self.appState = appState
    }

    func startMonitoring() {
        let process = Process()

        process.launchPath = "/usr/bin/log"
        process.arguments = [
            "stream",
            "--level", "debug",
            "--style", "ndjson",
            "--predicate",
            "(eventMessage CONTAINS 'IOHIDLibUserClient:0x' OR eventMessage == 'Time extension received' OR eventMessage CONTAINS 'received { messageType: RDR_to_PC_DataBlock')",
        ]

        let pipe = Pipe()
        process.standardOutput = pipe
        handle = pipe.fileHandleForReading

        process.launch()

        let fileDescriptor = handle.fileDescriptor
        source = DispatchSource.makeReadSource(fileDescriptor: fileDescriptor, queue: DispatchQueue.global(qos: .background))
        
        source.setEventHandler { [weak self] in
            if let validHandle = self?.handle {
                let data = validHandle.availableData
                if !data.isEmpty, let entry = try? JSONDecoder().decode(LogEntry.self, from: data) {
                    self?.updateState(with: entry)
                    self?.checkForNotification()
                }
            }
        }

        source.setCancelHandler { [weak self] in
            self?.handle?.closeFile()
        }

        source.resume()

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.clearPipeHandle()
        }
    }

    private func updateState(with entry: LogEntry) {
        if entry.processImagePath == "/kernel" && entry.senderImagePath.hasSuffix("IOHIDFamily") {
            touchState.fido2Needed =
                entry.eventMessage.contains("IOHIDLibUserClient:0x")
                && entry.eventMessage.hasSuffix("startQueue")
        }

        if entry.processImagePath.hasSuffix("usbsmartcardreaderd")
            && entry.subsystem.hasSuffix("CryptoTokenKit")
        {
            touchState.openPGPNeeded = entry.eventMessage == "Time extension received"
        }
        if entry.eventMessage.contains("received { messageType: RDR_to_PC_DataBlock") {
            touchState.fido2Needed = false
            touchState.openPGPNeeded = false
        }
    }

    private func checkForNotification() {
        DispatchQueue.main.async {
            self.appState.notify = self.touchState.checkToNotify()
        }
    }

    func stopMonitoring() {
        process.terminate()
        source.cancel()
        modalTimer?.invalidate()
    }

    private func clearPipeHandle() {
        DispatchQueue.global(qos: .background).async {
            if let validHandle = self.handle {
                _ = validHandle.availableData
            } else {
                print("Error: Handle is nil.")
            }
        }
    }
}
