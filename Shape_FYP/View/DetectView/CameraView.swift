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
    @Binding var mod: String?
    @Binding var selectedExercise: String?
    @Binding var exerciseList: [String]
    @Binding var exerciseCountList: [Int]
    @Binding var restTime: Int
    @Binding var isFinished: Bool
    @Binding var isStop: Bool
    
    let pushModel = try! VNCoreMLModel(for: P_last().model)
    let sitModel = try! VNCoreMLModel(for: S_last().model)

    
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
        Coordinator(detectedObjects: $detectedObjects, pushModel: pushModel, sitModel: sitModel, isDetecting: $isDetecting, selectedExercise: $selectedExercise, exerciseList: $exerciseList, exerciseCountList: $exerciseCountList, restTime: $restTime, mod: $mod, isFinished: $isFinished, isStop: $isStop)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        @Binding var detectedObjects: [String]
        let pushModel: VNCoreMLModel
        let sitModel: VNCoreMLModel
        @Binding var isDetecting: Bool
        @Binding var selectedExercise: String?
        @Binding var exerciseList: [String]
        @Binding var exerciseCountList: [Int]
        @Binding var restTime: Int
        @Binding var mod: String?
        var qty: Int //now doing how many repetitions for the exercise
        var exerciseCount: Int //now doing which exercise in the list
        @Binding var isFinished: Bool
        var toNext: Bool
        @Binding var isStop: Bool
        
        
        init(detectedObjects: Binding<[String]>, pushModel: VNCoreMLModel, sitModel: VNCoreMLModel, isDetecting: Binding<Bool>, selectedExercise: Binding<String?>, exerciseList: Binding<[String]>, exerciseCountList: Binding<[Int]>, restTime: Binding<Int>, mod: Binding<String?>, isFinished: Binding<Bool>, isStop: Binding<Bool>) {
            self._detectedObjects = detectedObjects
            self.pushModel = pushModel
            self.sitModel = sitModel
            self._isDetecting = isDetecting
            self._selectedExercise = selectedExercise
            self._exerciseList = exerciseList
            self._exerciseCountList = exerciseCountList
            self._restTime = restTime
            self._mod = mod
            self.qty = 0
            self.exerciseCount = 0
            self._isFinished = isFinished
            self.toNext = false
            self._isStop = isStop
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
            var model: VNCoreMLModel
            
            
            if mod == "training" {
                if selectedExercise == "push_up" {
                    model = pushModel
                } else{
                    model = sitModel
                }
            } else if mod == "custom"{
                
                model = pushModel
                
                if isDetecting == true {

                    if exerciseCount >= exerciseList.count {
                        print("finished")
                        isDetecting = false
                        isFinished = true
                    }
                    
                    
                    if isDetecting == true {
                        
                        toNext = false
                        
                        print(exerciseCount)
                        
                        if (exerciseList[exerciseCount] == "push_up") {
                            print("push")
                            model = pushModel
                        } else {
                            print("sit")
                            model = sitModel

                            
                        }
                        
                        if detectedObjects.count > 1 {
                            var ex = ""
                            print("qty: \(qty)")
                            if qty < exerciseCountList[exerciseCount] {  // if repetitions are not done for the exercise yet
                                if let index = exerciseList[exerciseCount].firstIndex(of: "_") {
                                    ex = String(exerciseList[exerciseCount].prefix(upTo: index))
                                    print("DOING: \(ex)")
                                }
                                qty = countRepetitions(exercise: ex, detectedObjects: detectedObjects)
                            } else if (toNext == false){
                                print("+1")
                                exerciseCount += 1
                                toNext = true
                                qty = 0
                            }
                        }
                    }
                }
                
            }else {
                model = pushModel
            }
            
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
                        
                        if firstLabel.confidence > 0.8 {
                            if self.detectedObjects.last != firstLabel.identifier {
                                self.detectedObjects.append(firstLabel.identifier)
                            }
                        }
                    }
                }

                

                

            }
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
            
            
            
        }
    
        func countRepetitions(exercise: String, detectedObjects: [String]) -> Int {
            var count = 0
            var isDown = false
            
            for (index, detectedObject) in detectedObjects.enumerated() {
                if detectedObject == "\(exercise)-down" {
                    isDown = true
                } else if detectedObject == "\(exercise)-up" {
                    if isDown {
                        count += 1
                        isDown = false
                    }
                }
            
            }

            return count
        }
    }
    
    
}
