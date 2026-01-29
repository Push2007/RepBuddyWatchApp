//
//  RepBuddyWatchAppApp.swift
//  RepBuddyWatchApp Watch App
//
//  Created by Pushkar Seshadri on 1/27/25.
//

import SwiftUI
import HealthKit

//How app starts when first being opened
enum Route: Hashable {
    case workoutType
    case session(workout: HKWorkoutActivityType, name: String)
}
@main
struct RepBuddyWatchApp_Watch_AppApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    @State private var navigationPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                StartScreen(navigationPath: $navigationPath)
                    .environmentObject(workoutManager)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .workoutType:
                            WorkoutType(navigationPath: $navigationPath)
                                .environmentObject(workoutManager)

                        case let .session(workout, name):
                            SessionPagingView(
                                navigationPath: $navigationPath,
                                workoutType: workout,
                                workoutName: name
                            )
                            .environmentObject(workoutManager)
                        }
                    }
            }
            .sheet(
                isPresented: $workoutManager.showingSummaryView,
                onDismiss: {
                    print("Sheet dismissed. Now the navigation will reset.")


                    navigationPath = NavigationPath() // Start's the navigation path over, taking us back to StartScreen

                    workoutManager.resetWorkout() // Reset all functions for the user
                }
            ) {
                SummaryView()
                    .environmentObject(workoutManager)
            }
        }
    }
}
