//
//  WorkoutManager.swift
//  MyWorkouts Watch App
//
//  Created by Pushkar Seshadri on 2/22/25.
//

import Foundation
import HealthKit
import CoreMotion


class WorkoutManager: NSObject, ObservableObject { //added to myWorkoutsApp bc its an observable object
    var selectedWorkout: HKWorkoutActivityType? {
            didSet {
                guard let selectedWorkout = selectedWorkout, let selectedWorkoutName = selectedWorkoutName else { return }
                startWorkout(workoutType: selectedWorkout, workoutName: selectedWorkoutName)
            }
        }
        
    var selectedWorkoutName: String? // New property
    @Published var elapsedTime: TimeInterval = 0
    private var timer: Timer?
    @Published var showingSummaryView: Bool = false {
        didSet {
            // Sheet dismissed
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }
    
    
    //REPVIEW STUFF
    
    
    let healthStore = HKHealthStore()
    @Published var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    // Replace old rep tracking with MotionTracker
    @Published var repCount: Int = 0
    private var motionTracker = MotionTracker()
    
    func startWorkout(workoutType: HKWorkoutActivityType, workoutName: String) {
            guard session?.state != .running else { return }
        
            

            let configuration = HKWorkoutConfiguration()
            configuration.activityType = workoutType
            configuration.locationType = .indoor

            do {
                session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
                builder = session?.associatedWorkoutBuilder()
                
                session?.delegate = self
                builder?.delegate = self
            } catch {
                print("Failed to start workout session: \(error.localizedDescription)")
                return
            }

            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

            if session?.state == .notStarted {
                session?.startActivity(with: Date())
                builder?.beginCollection(withStart: Date()) { success, error in
                    if let error = error {
                        print("Failed to begin data collection: \(error.localizedDescription)")
                    }
                }

                running = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { }
                
                // Start the appropriate exercise tracking
                if workoutType == .traditionalStrengthTraining {
                    switch workoutName {
                    case "Bench Press":
                        motionTracker.startTracking(exercise: .benchPress)
                    case "Squats":
                        motionTracker.startTracking(exercise: .squats)
                    case "Bicep Curls":
                        motionTracker.startTracking(exercise: .bicepCurls)
                    default:
                        print("Unknown workout type: \(workoutName)")
                    }
                }
            }
        }
    //repbuddy
    private let motionManager = CMMotionManager()
        private var lastAcceleration: Double = 0.0
        private var isCurling = false
        @Published var curlCount = 0
    
    func stopWorkout() {
            session?.end()
            motionTracker.stopTracking()
        }

        override init() {
            super.init()
            motionTracker.$repCount.assign(to: &$repCount)
        }
    
   
    
    func resetWorkout() {
        // Reset squat tracking
        
        
        // Reset general workout properties
        selectedWorkout = nil
        builder = nil
        session = nil // No need to call session?.end() here
        workout = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
        running = false
    }

    
    @Published var hasRequestedAuthorization = false
    // Request authorization to access HealthKit.
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        
        // The quantity type to write to the health store.
        let typesToShare: Set = [HKQuantityType.workoutType()]
            let typesToRead: Set = [
                HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
                HKObjectType.activitySummaryType()
            ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Authorization failed: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Authorization granted.")
                        completion(success)
                    }
                }
            }
    }
    // MARK: - State Control

    // The workout session state.
    @Published var running = false

    func pause() {
        session?.pause()
    }

    func resume() {
        session?.resume()
    }
    
    @Published var isPausing: Bool = false
    
    func togglePause() {
        guard !isPausing else { return } // Prevent rapid toggling
        isPausing = true

        if running {
            pause()
            running = false
            motionTracker.stopTracking() // Stop tracking reps when paused
        } else {
            resume()
            running = true
            if selectedWorkout == .traditionalStrengthTraining, let selectedWorkoutName = selectedWorkoutName {
                switch selectedWorkoutName {
                case "Bench Press":
                    motionTracker.startTracking(exercise: .benchPress)
                case "Squats":
                    motionTracker.startTracking(exercise: .squats)
                case "Bicep Curls":
                    motionTracker.startTracking(exercise: .bicepCurls)
                default:
                    print("Unknown workout: \(selectedWorkoutName)")
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isPausing = false
        }
    }

    @Published var isEndingWorkout = false

    func endWorkout() {
        guard !isEndingWorkout else { return } // Prevent multiple calls
        isEndingWorkout = true
        
        print("Ending workout, showingSummaryView: \(showingSummaryView)")
        // Only proceed if we're not already showing the summary
           guard !showingSummaryView else {
               isEndingWorkout = false
               return
           }
        
        session?.end()
        builder?.endCollection(withEnd: Date()) { success, error in
            if let error = error {
                print("Failed to end data collection: \(error.localizedDescription)")
            } else {
                print("Data collection ended successfully")
                self.saveWorkout()  // Call saveWorkout() after ending
            }
        }
        
        DispatchQueue.main.async {
            self.showingSummaryView = true // Trigger sheet
            print("Ending workout, showingSummaryView: \(self.showingSummaryView)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isEndingWorkout = false
        }

        updateRunningState()
    }

    func saveWorkout() {
        builder?.finishWorkout { workout, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error saving workout: \(error.localizedDescription)")
                    return
                }
                
                if let workout = workout {
                    self.workout = workout
                    print("Workout saved: \(workout)")
                } else {
                    print("Workout is nil")
                }
            }
        }
    }
    
    public func updateRunningState() {
        DispatchQueue.main.async {
                if let session = self.session {
                    _ = self.running
                    self.running = (session.state == .running)
                } else {
                    print("No active session found in updateRunningState.")
                    self.running = false
                }
            }
        }
    
    // MARK: - Workout Metrics
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            default:
                return
            }
        }
    }
    func recoverWorkoutSession() {
        healthStore.recoverActiveWorkoutSession { (session, error) in
            if let session = session {
                self.session = session
                self.session?.delegate = self
                self.builder = session.associatedWorkoutBuilder()
                self.builder?.delegate = self

                // Resume the session
                self.session?.resume()
            } else if let error = error {
                print("Failed to recover workout session: \(error.localizedDescription)")
            }
        }
    }
    
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        print("🔄 Workout session state changed from \(fromState.rawValue) to \(toState.rawValue)")
        DispatchQueue.main.async {
            switch toState {
            case .notStarted:
                self.running = false
            case .running:
                self.running = true
                if let selectedWorkout = self.selectedWorkout,
                   let selectedWorkoutName = self.selectedWorkoutName,
                   selectedWorkout == .traditionalStrengthTraining {
                    
                    switch selectedWorkoutName {
                    case "Bench Press":
                        self.motionTracker.startTracking(exercise: .benchPress)
                    case "Squats":
                        self.motionTracker.startTracking(exercise: .squats)
                    case "Bicep Curls":
                        self.motionTracker.startTracking(exercise: .bicepCurls)
                         
                    default:
                        print("Unknown workout: \(selectedWorkoutName)")
                    }
                }
            case .paused:
                self.running = false
                self.motionTracker.stopTracking() // Stop rep tracking when paused
            case .ended, .stopped, .prepared:
                self.running = false
                self.motionTracker.stopTracking() // Ensure reps stop when workout ends
            @unknown default:
                self.running = false
            }

            self.updateRunningState()
        }
    }

    // Add this method to handle session failures
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            print("Workout session failed with error: \(error.localizedDescription)")
        }
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            
            
            guard let quantityType = type as? HKQuantityType else { return }

            let statistics = workoutBuilder.statistics(for: quantityType)

            // Update the published values.
            updateForStatistics(statistics)
        }
        
        // Continuously update the elapsedTime from the builder
        DispatchQueue.main.async {
            self.elapsedTime = workoutBuilder.elapsedTime
        }
    }
}
