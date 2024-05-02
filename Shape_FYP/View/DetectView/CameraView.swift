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
    @Binding var isDetecting: Bool
    @Binding var heartRate: [Double]
    let model = try! VNCoreMLModel(for: last().model)

    
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

        
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                try device.lockForConfiguration()
                let frameRate = device.activeFormat.videoSupportedFrameRateRanges.first?.maxFrameRate ?? 10 // Default to 30 fps
                device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
                device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
                device.unlockForConfiguration()
            } catch {
                print("Error setting frame rate: \(error.localizedDescription)")
            }
        }


        
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(detectedObjects: $detectedObjects, model: model, isDetecting: $isDetecting)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        @Binding var detectedObjects: [String]
        let model: VNCoreMLModel
        @Binding var isDetecting: Bool
        
        init(detectedObjects: Binding<[String]>, model: VNCoreMLModel, isDetecting: Binding<Bool>) {
            self._detectedObjects = detectedObjects
            self.model = model
            self._isDetecting = isDetecting
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

                if self.isDetecting == true {
                    if let firstResult = results.first,
                       let firstLabel = firstResult.labels.first {
                        print(firstLabel.identifier)
                        print(firstLabel.confidence)
                        
                        if firstLabel.confidence > 0.8 {
                            if self.detectedObjects.last != firstLabel.identifier {
                                self.detectedObjects.append(firstLabel.identifier)
                            }
                        }
                    } else {
                        //print("nil")
                    }
                }

                
                
                

            }
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
            
            
            
        }
        
    }
    
}
