//
//  DetectedObjectsView.swift
//  FYP_YOLO
//
//  Created by Evan Wong on 7/3/2024.
//

import SwiftUI
import Vision

struct DetectedObjectsView: View {
    @Binding var detectedObjects: [String]

    var body: some View {
        List(detectedObjects, id: \.self) { object in
            Text(object)
            
        }
        Button("Save") {
            print(detectedObjects)
        }
    }
}
