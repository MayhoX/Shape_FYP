//
//  CountDownView.swift
//  Shape_FYP
//
//  Created by Evan Wong on 8/5/2024.
//

import SwiftUI

struct CountDownView: View {
    @Binding var restTime: Int
    @State private var timeRemaining: Int
    @Binding var isStop: Bool
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(restTime: Binding<Int>, isStop: Binding<Bool>) {
        _restTime = restTime
        _timeRemaining = State(initialValue: restTime.wrappedValue)
        _isStop = isStop
    }
     
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.green, lineWidth: 10)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(timeRemaining) / 10)
                .stroke(timeRemaining == 0 ? Color.green : Color.red, lineWidth: 10)
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut)
            
            Text("\(timeRemaining)")
                .font(.largeTitle)
                .foregroundColor(timeRemaining == 0 ? .green : .red)
                .padding()
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        isStop = false
                    }
                }
        }
    }
}


#Preview {
    CountDownView(restTime: .constant(10), isStop: .constant(true))
}
