//
//  ResultView.swift
//  Shape_FYP
//
//  Created by Evan Wong on 8/4/2024.
//

import SwiftUI

struct ResultView: View {
    let currentDate = Date()
    @Binding var detectedObjects: [String]
    @StateObject var exercisesViewModel = ExercisesViewModel()
    @StateObject var historyViewModel = HistoryViewModel()
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var calories = 10
    @State private var pushUpCount = 0
    @State private var sitUpCount = 0
    @State private var squatCount = 0
    
    var body: some View {
        VStack {
      
            HStack(spacing: 10) {
                Text("Date:")
                    .font(.title)
                Text(getFormattedDate())
                    .font(.headline)
                
                Text("Time:")
                    .font(.title)
                Text(getFormattedTime())
                    .font(.headline)
            }
            
            HStack(spacing: 10) {
                Text("Calories:")
                    .font(.title)
                Text("\(calories)")
                    .font(.headline)
                
            }
            
            HStack(spacing: 10) {
                Text("Ave Heart Rate:")
                    .font(.title)
                Text("80")
                    .font(.headline)
            }
            
            if !exercisesViewModel.exercises.isEmpty {
                ForEach(exercisesViewModel.exercises) { exercise in
                    HStack(spacing: 10) {
                        Text(exercise.name + ":")
                            .font(.title)
                        if (exercise.name == "sit-up")
                        {
                            Text("\(sitUpCount)")
                        }
                        else if (exercise.name == "squat")
                        {
                            Text("\(squatCount)")
                        }
                        else if (exercise.name == "push-up"){
                            Text("\(pushUpCount)")
                        }
                        
                    }
                }
            }
            
            
            
            NavigationLink(destination: HomeView()) {
                Text("Home")
                    .frame(width: UIScreen.main.bounds.width - 100, height: 20)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }.navigationBarBackButtonHidden(true)
            .onAppear {
                Task {
                    await exercisesViewModel.fetchExercises()
                    pushUpCount = countRepetitions(for: "push", in: detectedObjects)
                    sitUpCount = countRepetitions(for: "sit", in: detectedObjects)
                    squatCount = countRepetitions(for: "squat", in: detectedObjects)
                    await saveHistory(loginViewModel: loginViewModel, calories: String(calories), aveHeatRate: "1111", pushUpCount: pushUpCount, sitUpCount: sitUpCount, squatCount: squatCount)
                }
            }
    }
    
    
    func saveHistory(loginViewModel: LoginViewModel,calories: String, aveHeatRate: String, pushUpCount: Int, sitUpCount: Int, squatCount: Int) async{
        if let user = loginViewModel.currentUser {
            Task {
                try await historyViewModel.AddHistory(userID: user.id, date: getFormattedDate(), time: getFormattedTime(), calorie: calories, aveHeatRate: aveHeatRate, push_up: pushUpCount, sit_up: sitUpCount, squat: squatCount)
            }
        }
    }
    
    func countRepetitions(for exercise: String, in detectedObjects: [String]) -> Int {
        var count = 0
        var isDown = false
        
        for (index, detectedObject) in detectedObjects.enumerated() {
            if detectedObject == "\(exercise)-down" {
                isDown = true
            } else if detectedObject == "\(exercise)-up" {
                if isDown {
                    count += 1
                    isDown = false
                }
            }
        }
        
        return count
    }

    func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: currentDate)
    }
    
    func getFormattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: currentDate)
    }
    
}
    



#Preview {
    ResultView(detectedObjects: .constant(["push-up", "push-down", "push-down", "push-up", "push-up", "push-down", "push-up", "sit-down", "sit-up", "sit-down"]))
}


