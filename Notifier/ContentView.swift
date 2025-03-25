//
//  ContentView.swift
//  Notifier
//
//  Created by sokhrym on 25.03.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appModel: AppState

    var body: some View {
        VStack {
            Text("Main Content \(appModel.showModal)")
                .padding()
        }
    }
}

#Preview {
    ContentView().environmentObject(AppState())
}
