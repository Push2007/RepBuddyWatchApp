//
//  ContentView.swift
//  RepBuddy Watch App
//
//  Created by Ethan James on 11/12/24.
//

import SwiftUI
import HealthKit
struct StartScreen: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack {
            Image("Launch_Screen_Image")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 70)
            Spacer(minLength: 0)

            Text("Welcome!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Spacer(minLength: 10.0)

            NavigationLink(destination: WorkoutType(navigationPath: $navigationPath)
                .environmentObject(workoutManager) // Provide WorkoutManager here
            ) {
                Text("Get Started")
                    .font(.system(size: 25))
                    .foregroundColor(.white)
                    .padding(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            Spacer(minLength: 10)
        }
        .padding()
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            print("StartScreen appeared! Navigation path count: \(navigationPath.count)")
        }
    }
    
}


struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartScreen(navigationPath: .constant(NavigationPath()))
            .environmentObject(WorkoutManager())
    }
}
