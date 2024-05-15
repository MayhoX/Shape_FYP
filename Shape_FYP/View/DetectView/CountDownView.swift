//
//  CountDownView.swift
//  Shape_FYP
//
//  Created by Evan Wong on 8/5/2024.
//

import SwiftUI
import AVFoundation

struct CountDownView: View {
    @Binding var restTime: Int
    @State private var timeRemaining: Int
    @Binding var isStop: Bool
    @Binding var isDetecting: Bool
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(restTime: Binding<Int>, isStop: Binding<Bool>, isDetecting: Binding<Bool>) {
        _restTime = restTime
        _timeRemaining = State(initialValue: restTime.wrappedValue)
        _isStop = isStop
        _isDetecting = isDetecting
    }
     
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.green, lineWidth: 10)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(timeRemaining) / CGFloat(restTime))
                .stroke(timeRemaining <= 0 ? Color.green : Color.red, lineWidth: 10)
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
                        isDetecting = true
                    }
                }
        }
    }

    
}



#Preview {
    CountDownView(restTime: .constant(15), isStop: .constant(true), isDetecting: .constant(false))
}
