//
//  SessionPagingView.swift
//  RepBuddyWatchApp
//
//  Created by Pushkar Seshadri on 2/25/25.
//

import SwiftUI
import WatchKit
import HealthKit

//Ties the ControlsView, Metrics View, RepView, and Apple Music when a workout starts
struct SessionPagingView: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selection: Tab = .metrics
    @Binding var navigationPath: NavigationPath
    var workoutType: HKWorkoutActivityType
    var workoutName: String  // New property

    enum Tab {
        case controls, metrics, nowPlaying, reps
    }

    var body: some View {
            TabView(selection: $selection) {
                ControlsView().tag(Tab.controls)
                MetricsView().tag(Tab.metrics)
                RepView(workoutName: workoutName) // Pass workout name
                    .tag(Tab.reps)
                NowPlayingView().tag(Tab.nowPlaying)
            }
            .navigationTitle(workoutManager.selectedWorkout?.name ?? "Unknown Workout")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(selection == .nowPlaying || selection == .metrics)
            .onAppear {
                print("SessionPagingView appeared/worked with workout: \(workoutName)")
                if workoutManager.selectedWorkout == nil {
                    workoutManager.selectedWorkoutName = workoutName
                    workoutManager.selectedWorkout = workoutType
                    workoutManager.updateRunningState()
                }

            }
            .onChange(of: workoutManager.running) {
                displayMetricsView()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminanceReduced ? .never : .automatic))
            .onChange(of: isLuminanceReduced) {
                displayMetricsView()
            }
            .onDisappear {
                workoutManager.resetWorkout()
                print("disappeared")
            }
        
        
    }

    private func displayMetricsView() {
        withAnimation {
            selection = .metrics
        }
    }
}





#Preview {
    SessionPagingView(navigationPath: .constant(NavigationPath()), workoutType: .running, workoutName: "Running")//filler code
        .environmentObject(WorkoutManager())
}
