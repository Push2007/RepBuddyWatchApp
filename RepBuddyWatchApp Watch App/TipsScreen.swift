//
//  SettingsScreen.swift
//  RepBuddyWatchApp Watch App
//
//  Created by Pushkar Seshadri on 1/30/25.
//

import SwiftUI
//Screen for setting - need to customize
struct TipsScreen: View {
    var body: some View {
        ScrollView(.vertical){
            VStack(spacing: 10.0){
            Text("Tips")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("You have 3 seconds to get into position before RepBuddy begins to track your reps")
                .font(.body)
                .font(.system(size: 9))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            
            Text("Form is everything. RepBuddy is meant to track a repetition with proper form")
                .font(.body)
                .font(.system(size: 9))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            Text("RepBuddy is not 100% accurate, but through repeated testing, has shown to be very precise")
                .font(.body)
                .font(.system(size: 9))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
    
        }
    }
}
        
          }
        


#Preview {
    TipsScreen()
}
