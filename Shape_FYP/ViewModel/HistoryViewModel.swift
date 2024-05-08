//
//  HistoryViewModel.swift
//  Shape_FYP
//
//  Created by Evan Wong on 13/3/2024.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift

class HistoryViewModel: ObservableObject{
    @Published var history: History?
    @Published var histroys: [History] = []
    
    func fetchHistory(userID: String) async {
            do {
                let querySnapshot = try await Firestore.firestore().collection("users").document(userID).collection("historys").getDocuments()
                self.histroys = try querySnapshot.documents.compactMap {
                    try $0.data(as: History.self)
                }
                self.histroys.sort { $0.date > $1.date || ($0.date == $1.date && $0.time > $1.time) }
            } catch {
                print("ERROR FETCHING SHOPS: \(error)")
            }
        }
    

    func AddHistory(userID: String, date: String, time: String, calorie: String, aveHeatRate: String, push_up: Int, sit_up: Int, squat: Int) async throws{
        do{
            let history = History(id: UUID().uuidString, date: date, time: time, calorie: calorie, aveHeatRate: aveHeatRate, push_up: push_up, sit_up: sit_up, squat: squat)

            let encodedHistory = try Firestore.Encoder().encode(history)
            try await Firestore.firestore().collection("users").document(userID).collection("historys").document(history.id).setData(encodedHistory)
            
        } catch {
            print("ERROR ADD SHOP \(error.localizedDescription)")
        }
    }
    
}
