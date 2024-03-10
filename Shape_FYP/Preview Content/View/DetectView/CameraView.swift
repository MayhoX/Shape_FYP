//
//  CameraView.swift
//  FYP_YOLO
//
//  Created by Evan Wong on 10/3/2024.
//

import SwiftUI
import AVFoundation
import CoreVideo
import Vision
import CoreML

struct CameraView: UIViewRepresentable {
    let session = AVCaptureSession()
    @Binding var detectedObjects: [String]
    let model = try! VNCoreMLModel(for: last111().model)

    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return view
        }
        
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "cameraQueue"))
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
        ]
        session.addOutput(output)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(detectedObjects: $detectedObjects, model: model)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        @Binding var detectedObjects: [String]
        let model: VNCoreMLModel
    
        
        init(detectedObjects: Binding<[String]>, model: VNCoreMLModel) {
            self._detectedObjects = detectedObjects
            self.model = model
    
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
            
            
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                print("Error: Unable to get image from sample buffer")
                return
            }
            
            let request = VNCoreMLRequest(model: model) { request, error in
                guard error == nil else {
                    print("Error: \(String(describing: error))")
                    return
                }
                

                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    print("Error: Unable to get results")
                    return
                }

               
                if let firstResult = results.first,
                   let firstLabel = firstResult.labels.first {
                    print(firstLabel.identifier)
                    print(firstLabel.confidence)
                    
                    if firstLabel.confidence > 0.5 {
                        if self.detectedObjects.last != firstLabel.identifier {
                            self.detectedObjects.append(firstLabel.identifier)
                        }
                    }
                } else {
                    print("nil")
                }
                
                
                

            }
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
            
            
            
        }
        
    }
    
}
