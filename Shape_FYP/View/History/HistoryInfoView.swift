//
//  HistoryInfoView.swift
//  Shape_FYP
//
//  Created by Evan Wong on 2/5/2024.
//

import SwiftUI

struct HistoryInfoView: View {
    var history: History
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Section(header: Text("Date & Time").fontWeight(.bold)) {
                HStack {
                    Text("Date:")
                    Spacer()
                    Text(history.date)
                }
                HStack {
                    Text("Time:")
                    Spacer()
                    Text(history.time)
                }
            }
            .padding(.horizontal)
            
            Section(header: Text("Exercise Details").fontWeight(.bold)) {
                HStack {
                    Text("Calorie Burned:")
                    Spacer()
                    Text("\(history.calorie) cal")
                }
                HStack {
                    Text("Average Heart Rate:")
                    Spacer()
                    Text("\(history.aveHeatRate) bpm")
                }
                HStack {
                    Text("Push-ups:")
                    Spacer()
                    Text("\(history.push_up) times")
                }
                HStack {
                    Text("Sit-ups:")
                    Spacer()
                    Text("\(history.sit_up) times")
                }
                HStack {
                    Text("Squats:")
                    Spacer()
                    Text("\(history.squat) times")
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationBarTitle("History Details", displayMode: .inline)
    }
}


//#Preview {
//    HistoryInfoView()
//}
