//
//  AppState.swift
//  Notifier
//
//  Created by sokhrym on 25.03.2025.
//
import Foundation
import Combine

class AppState: ObservableObject {
    @Published var showModal = false {
        didSet {
            if showModal {
                print("showModal state changed to true")
            }
        }
    }
    var detector: Detector?
    private var cancellables: Set<AnyCancellable> = []

    init() {
        detector = Detector(appState: self)
    }
    
    func startMonitoring() {
        detector?.startMonitoring()
    }

    func stopMonitoring() {
        detector?.stopMonitoring()
        cancellables.forEach { $0.cancel() }
    }
}
