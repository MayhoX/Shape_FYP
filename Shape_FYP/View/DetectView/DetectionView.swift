//
//  DetectionView.swift
//  FYP_YOLO
//
//  Created by Evan Wong on 8/3/2024.
//

import SwiftUI
import AVFoundation
import CoreVideo
import Vision
import CoreML

struct DetectionView: View {
    @State private var detectedObjects = [String]()
    @State private var heartRate = [Double]()
    @State private var isDetecting = false
    @State private var showingAlert = false
    @State private var navigateToResult = false
    @State private var  isFinished = false
    @State private var isStop = false
    @Binding var selectedExercise: String?
    @Binding var mod: String?
    @Binding var exerciseList: [String]
    @Binding var exerciseCountList: [Int]
    @Binding var restTime: Int



    
    var body: some View {
        
        VStack {
            CameraView(detectedObjects: $detectedObjects, isDetecting: $isDetecting, heartRate: $heartRate, mod: $mod, selectedExercise: $selectedExercise, exerciseList: $exerciseList, exerciseCountList: $exerciseCountList, restTime: $restTime, isFinished: $isFinished, isStop: $isStop)
            
            
            DetectedObjectsView(detectedObjects: $detectedObjects)
            
            Text(mod ?? "")
            
            
            
            Button(action: {
                if isDetecting {
                    self.showingAlert = true
                    isDetecting = false
                } else {
                    self.isDetecting.toggle()
                }
            }) {
                Image(systemName: isDetecting ? "stop.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(isDetecting ? .red : .green)
            }
            .padding(.top, 20)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(isFinished ? "Detection Finished" : "Stop Detection"),
                    message: Text(isFinished ? "The custom training has finished." : "Are you sure you want to stop detection?"),
                    primaryButton: .default(Text("No")) {
                        self.isDetecting = true
                        
                    },
                    secondaryButton: .cancel(Text("Yes")) {
                        self.isDetecting = false
                        self.navigateToResult = true
                        
                    })
                    
            }.onChange(of: isFinished) { newValue in
                if newValue {
                    showingAlert = true
                }
            }
        

            NavigationLink(destination: ResultView(detectedObjects: $detectedObjects), isActive: $navigateToResult) {
                EmptyView()
            }
            
        }
    }
}


