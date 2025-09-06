//
//  SettingsScreen.swift
//  RepBuddyWatchApp Watch App
//
//  Created by Pushkar Seshadri on 1/30/25.
//

import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        Text("Settings")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
        Text("Coming Soon...")
            .font(.body)
            .font(.system(size: 10))
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
          }


#Preview {
    SettingsScreen()
}
