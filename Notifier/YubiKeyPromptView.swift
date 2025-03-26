//
//  YubiKeyPromptView.swift
//  Notifier
//
//  Created by sokhrym on 26.03.2025.
//
import SwiftUI

struct YubiKeyPromptView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Please touch your YubiKey")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.top, 20)

            Image(systemName: "key.fill")
                .font(.system(size: 120))
                .foregroundColor(.blue)
                .padding()
        }
        .frame(width: 270, height: 270)
        .padding()
    }
}

#Preview {
    YubiKeyPromptView()
}
