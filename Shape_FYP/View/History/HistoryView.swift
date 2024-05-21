//
//  HistoryView.swift
//  Shape_FYP
//
//  Created by Evan Wong on 8/4/2024.
//

import SwiftUI

struct HistoryView: View {
    @StateObject var historyViewModel = HistoryViewModel()
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        List(historyViewModel.histroys) { history in
            NavigationLink(destination: HistoryInfoView(history: history)) {
                HistoryListRowView(history: history) {
                    // This closure is required, but it can be empty as per your current implementation
                }
            }
        }
        .onAppear {
            if let user = loginViewModel.currentUser {
                Task {
                    try await historyViewModel.fetchHistory(userID: user.id)
                }
            }
        }
        .navigationTitle("History")
        .toolbar {
            Button(action: {
                alertMessage = """
                Calorie Status Information:
                
                • Green: Calorie >= 100 (Good)
                • Orange: 50 < Calorie < 100 (Average)
                • Red: Calorie <= 50 (Bad)
                """
                showAlert = true
            }) {
                Image(systemName: "exclamationmark.circle")
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Calorie Status"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        
    }
}



struct HistoryListRowView: View {
    var history: History
    var onSelected: () -> Void // Closure to handle row selection
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {

                Text(history.date)
                    .font(.headline)
                Text(history.time)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(history.calorie)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            StatusIndicator(calorie: Double(history.calorie) ?? 0)
        }
        .padding()
        .onTapGesture {
            onSelected()
        }
    }
}

struct StatusIndicator: View {
    var calorie: Double
    var status: String {
        if calorie >= 100 {
            return "Good"
        } else if calorie > 50 {
            return "Average"
        } else {
            return "Bad"
        }
    }
    var color: Color {
        switch status {
            case "Good":
                return .green
            case "Average":
                return .orange
            default:
                return .red
        }
    }
    
    var body: some View {
        Text(status)
            .font(.footnote)
            .foregroundColor(.white)
            .padding(8)
            .background(color)
            .clipShape(Capsule())
    }
}
