//
//  ContentView.swift
//  Notifier
//
//  Created by sokhrym on 26.03.2025.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appModel: AppState
    @Environment(\.colorScheme) var colorScheme


    var body: some View {
        VStack(spacing: 20) {
            Text("Yubikey Touch Detector")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top)

            Toggle("Enable Modal", isOn: $appModel.isModalEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .padding(.horizontal)

            Toggle("Enable Sound", isOn: $appModel.isSoundEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .padding(.horizontal)

        }
        .padding()
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

#Preview {
    ContentView().environmentObject(AppState())
}
