//
//  LoginView.swift
//  FYP_YOLO
//
//  Created by Evan Wong on 10/3/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = "aa@aa.com"
    @State private var password: String = "qqqqqq"
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var showAlert = false
    
    
    var body: some View {
        NavigationStack{
            VStack{
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 180, height: 120)
                    .padding(.vertical, 32)
                
                VStack{
                    TextField("Email", text: $email)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(UIColor.label), lineWidth: 3)
                        )
                        .cornerRadius(10.0)
                        .shadow(radius: 1)
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        .padding(.bottom, 5)
                        .keyboardType(.emailAddress)
                    
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(UIColor.label), lineWidth: 3)
                        )
                        .cornerRadius(10.0)
                        .shadow(radius: 1)
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        .padding(.bottom, 20)
                    
                    
                    
                    
                    Button(action: {
                        Task {
                            do {
                                try await loginViewModel.signIn(email: email, password: password)
                            } catch {
                                showAlert = true
                            }
                            
                        }
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width - 32, height: 52)
                            .background(Color.blue)
                            .cornerRadius(15.0)
                            .disabled(!formIsValid)
                            .opacity(formIsValid ? 1.0 : 0.5)
                        
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Login Error"),
                            message: Text("Invalid email or password. Please try again."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    Spacer()
                    
                    
                    NavigationLink {
                        RegisterView()
                            .navigationBarBackButtonHidden()
                    } label: {
                        HStack{
                            Text("Don't have an account?")
                            Text("Sign up")
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 14))
                    }
                }
                
            }
        }
    }
}

extension LoginView: AuthProtocol {
    var formIsValid: Bool {
        return !email.isEmpty &&
        email.contains("@") &&
        !password.isEmpty &&
        password.count > 5
    }
}

 #Preview {
     LoginView()
 }

