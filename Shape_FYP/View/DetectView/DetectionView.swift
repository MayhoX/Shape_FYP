//
//  DetectionView.swift
//  FYP_YOLO
//
//  Created by Evan Wong on 8/3/2024.
//

import SwiftUI

struct DetectionView: View {
    @State private var detectedObjects = [String]()
    @State private var heartRate = [Double]()
    @State private var isDetecting = false
    @State private var showingAlert = false
    @State private var navigateToResult = false
    
    var body: some View {
        VStack {
            CameraView(detectedObjects: $detectedObjects, isDetecting: $isDetecting, heartRate: $heartRate)
            
            DetectedObjectsView(detectedObjects: $detectedObjects)
            
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
                    title: Text("Stop Detection"),
                    message: Text("Are you sure you want to stop detection?"),
                    primaryButton: .default(Text("No")) {
                        self.isDetecting = true
    
                    },
                    secondaryButton: .cancel(Text("Yes")) {
                        self.isDetecting = false
                        self.navigateToResult = true
                        
                    }
                )
            }
            NavigationLink(destination: ResultView(detectedObjects: $detectedObjects), isActive: $navigateToResult) {
                EmptyView()
            }
            
        }
    }
}

#Preview {
    DetectionView()
}
