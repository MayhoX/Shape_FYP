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
import FirebaseAuth
import FirebaseCore

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
    
    
    func signIn(email: String, password: String) async throws {    //signIn
            
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            self.login = true           //set login to true
            await fetchUser()
            
        }
        
        
        func signUp(email: String, password: String, firstName: String, lastName: String) async throws {  //signuUp
            do {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                self.userSession = result.user
                let user = User(id: result.user.uid, firstName: firstName, lastName: lastName, email: email, state: "user")
                let encodedUser = try Firestore.Encoder().encode(user)
                try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
                await fetchUser()
            } catch {
                print("ERROR SIGN UP \(error.localizedDescription)")
            }
        }
        
        
        func signOut() async throws{
            do {
                try Auth.auth().signOut()
                self.userSession = nil
                self.currentUser = nil
                self.login = false
            } catch {
                print("ERROR SIGN OUT \(error.localizedDescription)")
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
