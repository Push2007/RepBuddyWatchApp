//
//  ContentView.swift
//  RepBuddy Watch App
//
//  Created by Ethan James on 11/12/24.
//

//The beginning screen of the app
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

            Button {
                navigationPath.append(Route.workoutType)
            } label: {
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
            print("The StartScreen appears! Navigation path count: \(navigationPath.count)")
        }
    }
    
}


struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartScreen(navigationPath: .constant(NavigationPath()))
            .environmentObject(WorkoutManager())
    }
}
