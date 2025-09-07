//
//  RepView!!!.swift
//  RepBuddyWatchApp Watch App
//
//  Created by Pushkar Seshadri on 3/19/25.
//

//View used to show user how many repetitions they completed
import SwiftUI

struct RepView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    var workoutName: String

    var body: some View {
        VStack {
            Text("Counting \(workoutName)")
                .font(.title2)
                .multilineTextAlignment(.center)
                .lineLimit(4)
            
            
            Text("\(workoutManager.repCount)") // Updated to use MotionTracker's rep count
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .bold()
                .foregroundColor(.green)

            Text("reps completed")
                .font(.caption)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    RepView(workoutName: "Bicep Curls")
        .environmentObject(WorkoutManager())
}

