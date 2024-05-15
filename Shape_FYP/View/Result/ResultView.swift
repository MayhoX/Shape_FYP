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
    @Binding var heartRate: [Double]
    @StateObject var exercisesViewModel = ExercisesViewModel()
    @StateObject var historyViewModel = HistoryViewModel()
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var calories = ""
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
                Text(aveHeartRate(hartRate: heartRate))
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
//                        else if (exercise.name == "squat")
//                        {
//                            Text("\(squatCount)")
//                        }
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
                    
                    calories = countCalories(exercises: exercisesViewModel.exercises, pushUpCount: pushUpCount, sitUpCount: sitUpCount, squatCount: squatCount)
                                      
                    await saveHistory(loginViewModel: loginViewModel, calories: String(calories), aveHeatRate: aveHeartRate(hartRate: heartRate), pushUpCount: pushUpCount, sitUpCount: sitUpCount, squatCount: squatCount)
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

    
    func countCalories(exercises: [Exercises], pushUpCount: Int, sitUpCount: Int, squatCount: Int) -> String {
        var totalCalories = 0.0
            
            for exercise in exercises {
                print (totalCalories)
                switch exercise.name {
                case "push-up":
                    totalCalories += Double(pushUpCount) * (Double(exercise.calories) ?? 0)
                case "sit-up":
                    totalCalories += Double(sitUpCount) * (Double(exercise.calories) ?? 0)
                case "squat":
                    totalCalories += Double(squatCount) * (Double(exercise.calories) ?? 0)
                default:
                    break
                }
            }
            
            return String(format: "%.1f", totalCalories)
        }
    
    
    func aveHeartRate(hartRate: [Double]) -> String {
        var total = 0.0
        for rate in hartRate {
            total += rate
        }
        let ave = total / Double(hartRate.count)
        return String(format: "%.1f", ave)
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
    ResultView(detectedObjects: .constant(["push-up", "push-down", "push-down", "push-up", "push-up", "push-down", "push-up", "sit-down", "sit-up", "sit-down"]), heartRate: .constant([11.0 ,22.9 ,33.2]))
}



