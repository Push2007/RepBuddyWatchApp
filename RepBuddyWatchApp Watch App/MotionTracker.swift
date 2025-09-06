import Foundation
import CoreMotion

// Renamed enum to avoid conflict with `WorkoutType` SwiftUI view
enum TrackedExercise {
    case benchPress, squats, bicepCurls
}

class MotionTracker: ObservableObject {
    private let motionManager = CMMotionManager()
    private var previousTime: TimeInterval = 0
    private var velocityX: Double = 0
    private var positionX: Double = 0
    private var previousAccelerometerData: CMAcceleration?
    private var k: Int = 0
    private var lastPosition = 0 // -1 = bottom, 1 = top
    private var lastBottomTime: Date?
    private var lastRepTime: Date?
    private var lastX: Double = 0.0
    private var sessionStartTime: Date? = Date()
     // Set this when workout begins
    
    @Published var repCount: Int = 0
    private var lastDirection: Int = 0 // -1 for downward, 1 for upward
    private var currentExercise: TrackedExercise?

    init() {
        motionManager.accelerometerUpdateInterval = 0.01 // 100Hz update rate
    }

    // Start tracking based on the selected exercise
    func startTracking(exercise: TrackedExercise) {
        currentExercise = exercise
        sessionStartTime = Date()
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self, let acceleration = data?.acceleration else { return }
            
            switch exercise {
            case .benchPress:
                self.trackBenchPress(acceleration: acceleration)
            case .squats:
                self.trackSquats(acceleration: acceleration)
            case .bicepCurls:
                self.trackBicepCurls(acceleration: acceleration)
            }
        
        }
    }

    func stopTracking() {
        motionManager.stopAccelerometerUpdates()
    }

    // MARK: - Individual Tracking Methods

    private func trackBenchPress(acceleration: CMAcceleration) {
        let topThreshold = 0.9 //.
        let bottomThreshold = 0.5
        let maxRepDuration: TimeInterval = 3.0
        let cooldownAfterRep: TimeInterval = 0.4
        let warmUpDelay: TimeInterval = 5.0
        
        let x = acceleration.x
        let now = Date()
        
        // Wait 3 seconds before starting to track
            guard let start = sessionStartTime, now.timeIntervalSince(start) >= warmUpDelay else {
                if let start = sessionStartTime {
                    let timeLeft = warmUpDelay - now.timeIntervalSince(start)
                    print("⏳ Warming up... \(String(format: "%.1f", timeLeft))s left")
                }
                lastX = x
                return
            }	
        
        // Calculate motion direction
        let isMovingDown = x < lastX
        
        // Debounce: Don’t process if still in cooldown after last rep
        if let lastRep = lastRepTime, now.timeIntervalSince(lastRep) < cooldownAfterRep {
            lastX = x
            return
        }
        
        if x < bottomThreshold && isMovingDown {
            if lastPosition != -1 {
                lastPosition = -1
                lastBottomTime = now
                print("⬇️ Squat Down Detected at \(now)")
            }
        } else if x > topThreshold {
            if lastPosition == -1, let bottomTime = lastBottomTime {
                let timeSinceBottom = now.timeIntervalSince(bottomTime)
                if timeSinceBottom <= maxRepDuration {
                    repCount += 1
                    lastRepTime = now
                    print("Squat Rep Count: \(repCount) (within \(String(format: "%.2f", timeSinceBottom))s)")
                } else {
                    print("Rep too slow: \(String(format: "%.2f", timeSinceBottom))s — not counted")
                }
                lastPosition = 1
                lastBottomTime = nil
            }
        }
        
        lastX = x // Save last x for next time to compare motion direction

    }

    
    
    private func trackSquats(acceleration: CMAcceleration) {
        let topThreshold = 0.75 //.8
        let bottomThreshold = 0.65
        let maxRepDuration: TimeInterval = 3.0
        let cooldownAfterRep: TimeInterval = 1.6
        let warmUpDelay: TimeInterval = 5.0
        
        let x = acceleration.x
        let now = Date()
        
        // Wait 3 seconds before starting to track
            guard let start = sessionStartTime, now.timeIntervalSince(start) >= warmUpDelay else {
                if let start = sessionStartTime {
                    let timeLeft = warmUpDelay - now.timeIntervalSince(start)
                    print("⏳ Warming up... \(String(format: "%.1f", timeLeft))s left")
                }
                lastX = x
                return
            }
        
        // Calculate motion direction
        let isMovingDown = x < lastX
        
        // Debounce: Don’t process if still in cooldown after last rep
        if let lastRep = lastRepTime, now.timeIntervalSince(lastRep) < cooldownAfterRep {
            lastX = x
            return
        }
        
        if x < bottomThreshold && isMovingDown {
            if lastPosition != -1 {
                lastPosition = -1
                lastBottomTime = now
                print("⬇️ Squat Down Detected at \(now)")
            }
        } else if x > topThreshold {
            if lastPosition == -1, let bottomTime = lastBottomTime {
                let timeSinceBottom = now.timeIntervalSince(bottomTime)
                if timeSinceBottom <= maxRepDuration {
                    repCount += 1
                    lastRepTime = now
                    print("Squat Rep Count: \(repCount) (within \(String(format: "%.2f", timeSinceBottom))s)")
                } else {
                    print("Rep too slow: \(String(format: "%.2f", timeSinceBottom))s — not counted")
                }
                lastPosition = 1
                lastBottomTime = nil
            }
        }
        
        lastX = x // Save last x for next time to compare motion direction
    }
    
    private func trackBicepCurls(acceleration: CMAcceleration) {
        let threshold: Double = 0.56
        let warmUpDelay: TimeInterval = 5.0
        let now = Date()

        guard let start = sessionStartTime, now.timeIntervalSince(start) >= warmUpDelay else {
            if let start = sessionStartTime {
                let timeLeft = warmUpDelay - now.timeIntervalSince(start)
                print("⏳ Get ready... \(String(format: "%.1f", timeLeft))s left")
            }
            return
        }

        if acceleration.x > threshold {
            if lastDirection != 1 {
                repCount += 1
                print("💪 Bicep Curl Rep Count: \(repCount)")
            }
            lastDirection = 1
        } else if acceleration.x < -threshold {
            lastDirection = -1
        }
    }
    
    


}
