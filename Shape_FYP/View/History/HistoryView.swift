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
            }
            Spacer()
        }
        .padding()
        .onTapGesture {
            onSelected()
        }
    }
}
