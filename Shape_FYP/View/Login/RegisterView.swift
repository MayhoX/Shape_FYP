//
//  ReigsterView.swift
//  DeliverApp
//
//  Created by Evan Wong on 14/1/2024.
//

import SwiftUI

struct RegisterView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModle: AuthViewModel
    
    var body: some View {
        VStack{
            Image("logo")
                .resizable()
                .scaledToFill()
                .frame(width: 180, height: 120)
                .padding(.vertical, 32)
            
            VStack{
                TextField("Frist Name", text: $firstName)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(UIColor.label), lineWidth: 3)
                    )
                    .cornerRadius(10.0)
                    .shadow(radius: 1)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                
                TextField("Last Name", text: $lastName)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(UIColor.label), lineWidth: 3)
                    )
                    .cornerRadius(10.0)
                    .shadow(radius: 1)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                
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

                    .padding(.bottom, 5)
                
                SecureField("Confirm Password", text: $confirmPassword)
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
                        try await viewModle.signUp(email: email,
                                                   password: password,
                                                   firstName: firstName,
                                                   lastName: lastName)
                        dismiss()
                    }
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width - 32, height: 52)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                        .disabled(!formIsValid)
                        .opacity(formIsValid ? 1.0 : 0.5)
                }
                
                
                Spacer()
                
                Button{
                    dismiss()
                } label: {
                    HStack{
                        Text("Have an account?")
                        Text("Sign in")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
                
                
            }
        }
    }
}


extension RegisterView: AuthProtocol {
    var formIsValid: Bool {
        return !email.isEmpty &&
        email.contains("@") &&
        !password.isEmpty &&
        password.count > 5 &&
        password == confirmPassword &&
        !firstName.isEmpty &&
        !lastName.isEmpty
    }
}


#Preview {
    RegisterView()
}
