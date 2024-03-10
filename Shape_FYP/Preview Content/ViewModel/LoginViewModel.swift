//
//  LoginViewModel.swift
//  FYP_YOLO
//
//  Created by Evan Wong on 10/3/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseAnalytics

protocol AuthProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class LoginViewModel: ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var login: Bool

    init() {
        self.login = false
        userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            self.currentUser = try snapshot.data(as: User.self)
        } catch {
            print("ERROR GETTING USER DOC \(error.localizedDescription)")
        }
    }
}
