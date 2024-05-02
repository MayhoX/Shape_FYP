//
//  ExercisesViewModel.swift
//  Shape_FYP
//
//  Created by Evan Wong on 9/4/2024.
//

import Foundation
import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseAnalytics
import FirebaseCore

class ExercisesViewModel : ObservableObject {
    @Published var exercises: [Exercises] = []
    private var db = Firestore.firestore()
    
    
    func fetchExercises() async{
        do {
            let querySnapshot = try await Firestore.firestore().collection("exercises").getDocuments()
            self.exercises = try querySnapshot.documents.compactMap {
                try $0.data(as: Exercises.self)
            }
            print("Exercises fetched successfully: \(self.exercises)")
        } catch {
            print("Error fetching exercises: \(error)")
        }
    }
    

    
}
