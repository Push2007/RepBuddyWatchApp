//
//  ScreenTwo.swift
//  RepBuddy Watch App
//
//  Created by Ethan James on 11/12/24.
//

// Screen where users choose which exercise they want to track
import SwiftUI
import HealthKit



struct WorkoutType: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var navigationPath: NavigationPath
    
    var workoutTypes: [(type: HKWorkoutActivityType, name: String)] = [
        (.traditionalStrengthTraining, "Bench Press"),
        (.traditionalStrengthTraining, "Bicep Curls"),
        (.traditionalStrengthTraining, "Squats"),
    ]

    var body: some View {
        List(workoutTypes, id: \.name) { workout in
            Button(workout.name) {
                navigationPath.append(
                    Route.session(
                        workout: workout.type,
                        name: workout.name
                    )
                )
            }
        }
        .listStyle(.carousel)
        .navigationTitle("Select an Exercise")
        .onAppear {
            workoutManager.requestAuthorization { _ in }
        }
    }
}



#Preview {
    WorkoutType(navigationPath: .constant(NavigationPath()))
        .environmentObject(WorkoutManager())
}



extension HKWorkoutActivityType: @retroactive Identifiable {
    public var id: UInt {
        rawValue
    }

    var name: String {
        switch self {
        case .running:
            return "Run"
        case .cycling:
            return "Bike"
        case .walking:
            return "Walk"
        case .traditionalStrengthTraining:
            return ""
        default:
            return ""
        }
    }
}
