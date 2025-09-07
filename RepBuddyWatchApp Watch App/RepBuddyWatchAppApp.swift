//
//  RepBuddyWatchAppApp.swift
//  RepBuddyWatchApp Watch App
//
//  Created by Pushkar Seshadri on 1/27/25.
//

import SwiftUI

//How app starts when first being opened
@main
struct RepBuddyWatchApp_Watch_AppApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    @State private var navigationPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                StartScreen(navigationPath: $navigationPath)
                    .environmentObject(workoutManager) // <- Add this line
            }
            .sheet(isPresented: $workoutManager.showingSummaryView, onDismiss: {
                print("Sheet dismissed, resetting navigationPath")
                workoutManager.showingSummaryView = false // Reset the state
                workoutManager.selectedWorkout = nil
            }) {
                SummaryView(navigationPath: $navigationPath)
                    .environmentObject(workoutManager)
            }
            
            
            
        }
        
    }
}
