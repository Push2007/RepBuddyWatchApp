# RepBuddy
RepBuddy is an Apple Watch app that tracks the number of repetitions you complete on an exercise. So far, we have been able to track bicep curls, squats, and bench press.

**Link to portfolio:** https://pushkarseshadri.wixsite.com/repbuddy

**Link to app:** https://apps.apple.com/us/app/rep-buddy/id6758496444

## How It's Made:

**Tech used:** Swift, Apple Libraries, Xcode

Using Apple HealthKit and CoreMotion libraries, we were able to track the motion on the x, y, and z planes in order to create a code which can count a repetition. This is made possible due to the accelerometer built into the Apple Watch. We created a series of tests to create a range of acceleration that the Apple Watch goes through when doing a repetition of a bicep curl, squat, and a bench press. Through the data we collected, we found the most optimal ranges for each exercise, and now we are working to track more exercise exercises.

## Lessons Learned:

Through this project, I have learned how to integrate Apple Libraries into my Xcode projects, create aesthetic UI's, using elapsed time, implementing motion rings, bpm, and calories burnt, and most importantly, creating a MotionTracker class that can detect repetitions for the bicep curl, bench press, and squat. 

