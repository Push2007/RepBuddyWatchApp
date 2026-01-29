//
//  SummaryView.swift
//  MyWorkouts Watch App
//
//  Created by Pushkar Seshadri on 2/22/25.
//

import SwiftUI
import HealthKit

//View used to give a summary of your workout
struct SummaryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var workoutManager: WorkoutManager

    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    var body: some View {
        if workoutManager.workout == nil { // Should never be like this
            ProgressView("Saving workout")
                .navigationBarHidden(true)
        } else { // Should be like this
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    SummaryMetricView(
                        title: "Total Time",
                        value: durationFormatter
                            .string(from: workoutManager.workout?.duration ?? 0.0) ?? ""
                    ).accentColor(Color.yellow)
                    
                    // New Metric for total reps
                    SummaryMetricView(
                        title: "Total Reps Completed",
                        value: "\(workoutManager.repCount) reps"
                    ).accentColor(Color.green)
                    
                    SummaryMetricView(
                        title: "Total Energy",
                        value: Measurement(
                            value: {
                                guard let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
                                      let statistics = workoutManager.workout?.statistics(for: energyType),
                                      let total = statistics.sumQuantity() else {
                                    return 0
                                }
                                return total.doubleValue(for: .kilocalorie())
                            }(),
                            unit: UnitEnergy.kilocalories
                        ).formatted(
                            .measurement(
                                width: .abbreviated,
                                usage: .workout
                            )
                        )
                    ).accentColor(Color.pink)
                
                    SummaryMetricView(
                        title: "Avg. Heart Rate",
                        value: workoutManager.averageHeartRate
                            .formatted(
                                .number.precision(.fractionLength(0))
                            )
                        + " bpm"
                    ).accentColor(Color.red)
                    
                    Text("Activity Rings")
                    ActivityRingsView(healthStore: workoutManager.healthStore)
                        .frame(width: 50, height: 50)
                    
                    Button("Done") {
                        dismiss()
                        
                    }
                    
                }
                .scenePadding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SummaryView()
        .environmentObject(WorkoutManager())
}

struct SummaryMetricView: View {
    var title: String
    var value: String

    var body: some View {
        Text(title)
        Text(value)
            .font(.system(.title2, design: .rounded)
                    .lowercaseSmallCaps()
            )
            .foregroundColor(.accentColor)
        Divider()
    }
}
