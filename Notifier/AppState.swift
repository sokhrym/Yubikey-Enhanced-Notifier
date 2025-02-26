//
//  AppState.swift
//  Notifier
//
//  Created by sokhrym on 26.03.2025.
//
import Foundation
import Combine

class AppState: ObservableObject {
    @Published var notify: Bool = false {
        didSet {
            if notify {
                print("Notification triggered.")
            } else {
                print("Notification closed.")
            }
        }
    }
    
    @Published var isSoundEnabled: Bool = false
    {
        didSet {

            print("isSoundEnabled changed: \(isSoundEnabled)")
        }
    }
    @Published var isModalEnabled: Bool = true
    {
        didSet {

            print("isModalEnabled changed: \(isModalEnabled)")

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
