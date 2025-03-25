//
//  YubiKeyPromptView.swift
//  Notifier
//
//  Created by sokhrym on 25.03.2025.
//
import SwiftUI

struct YubiKeyPromptView: View {
    @EnvironmentObject var appModel: AppState

    var body: some View {
        VStack {
            Text("Please touch your YubiKey")
                .font(.title)
                .padding()
            Image(systemName: "key.fill")
                .font(.system(size: 100))
                .padding()
            Button("Dismiss") {
                appModel.showModal = false
            }
            .padding()
        }
        .frame(width: 480, height: 270)
    }
}

//
//#Preview {
//    YubiKeyPromptView()
//}
