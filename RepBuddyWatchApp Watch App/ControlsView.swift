//
//  ControlsView.swift
//  MyWorkouts Watch App
//
//  Created by Pushkar Seshadri on 2/22/25.
//

//Screen which pauses/plays the workout. When paused, does not track repetitions
import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        HStack {
            VStack {
                Button {
                    if let session = workoutManager.session {
                        if session.state == .running || session.state == .paused {
                            workoutManager.endWorkout()
                        } else {
                            print("Workout session is already ended or in an invalid state: \(session.state)")// Should not be the case
                        }
                    }
                } label: {
                    Image(systemName: "xmark")
                }
                .tint(Color.red)
                .font(.title2)
                .disabled(workoutManager.isEndingWorkout) // Disable while ending
                
                Text("End")
                
            }

            VStack {
                Button {
                    workoutManager.togglePause()
                } label: {
                    Image(systemName: workoutManager.running ? "pause" : "play") // Starts as "pause"
                }
                .tint(Color.yellow)
                .font(.title2)
                Text(workoutManager.running ? "Pause" : "Resume") // Text starts as "Pause"
            }
        }
    }
}


#Preview {
    ControlsView()
        .environmentObject(WorkoutManager())
}
