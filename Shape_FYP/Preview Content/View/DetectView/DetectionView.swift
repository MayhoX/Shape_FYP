//
//  DetectionView.swift
//  FYP_YOLO
//
//  Created by Evan Wong on 8/3/2024.
//

import SwiftUI

struct DetectionView: View {
    @State private var detectedObjects = [String]()
    
    
    var body: some View {
        VStack {
            Button("Remove") {
                detectedObjects.removeAll()
            }
            CameraView(detectedObjects: $detectedObjects)
            DetectedObjectsView(detectedObjects: $detectedObjects)
        }
    }
    
    

}

#Preview {
    DetectionView()
}
