//
//  HomeView.swift
//  Shape_FYP
//
//  Created by Evan Wong on 9/4/2024.
//

import SwiftUI


struct HomeView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var showingAlert = false
    @StateObject var historyViewModel = HistoryViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                NavigationLink(destination: DetectionView()) {
                    Text("Start")
                        .frame(width: UIScreen.main.bounds.width - 100, height: 20)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: HistoryView()) {
                    Text("History")
                        .frame(width: UIScreen.main.bounds.width - 100, height: 20)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                
                Button("Logout") {
                    showingAlert = true
                }
                .frame(width: UIScreen.main.bounds.width / 2, height: 20)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .navigationBarTitle("Home", displayMode: .inline)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Logout"),
                      message: Text("Are you sure you want to log out?"),
                      primaryButton: .destructive(Text("Logout")) {
                    Task {
                        try await loginViewModel.signOut()
                    }
                }, secondaryButton: .cancel(Text("Cancel")))
            }
        }.navigationBarBackButtonHidden(true)
    }
}



#Preview {
    HomeView()
}
