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
import HealthKit

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
    
    let healthStore = HKHealthStore()
    let pushModel = try! VNCoreMLModel(for: P_last().model)
    let sitModel = try! VNCoreMLModel(for: S_last().model)
    
    @State var heartRateQueryTimer: Timer?
    let heartRateQueryInterval: TimeInterval = 5
    
    @State var heartRateQuery: HKAnchoredObjectQuery?
    @State var anchor: HKQueryAnchor?
    
    
    //==============================
    
    // Function to request authorization for HealthKit
        func requestAuthorization() {
            print("Requesting authorization for heart rate")
            let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            healthStore.requestAuthorization(toShare: [], read: [heartRateType]) { success, error in
                if success {
                    self.startHeartRateQuery()
                } else {
                    print("Failed to request authorization for heart rate: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        // Function to start querying heart rate data
        func startHeartRateQuery() {
            print("Starting heart rate query")
            guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
            let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { query, completionHandler, error in
                guard error == nil else {
                    print("Error observing heart rate: \(error!.localizedDescription)")
                    return
                }

                self.fetchLatestHeartRate { heartRate in
                    DispatchQueue.main.async {
                        if (isDetecting){
                            self.heartRate.append(heartRate)
                        }
                    }
                }
            }

            healthStore.execute(query)
        }
    
        // Function to fetch the latest heart rate data
        func fetchLatestHeartRate(completion: @escaping (Double) -> Void) {
            print("Fetching latest heart rate")
            guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
                guard let sample = samples?.first as? HKQuantitySample else {
                    print("No heart rate sample available: \(error?.localizedDescription ?? "Unknown error")")
                    completion(0.0)
                    return
                }

                completion(sample.quantity.doubleValue(for: HKUnit(from: "count/min")))
            }

            healthStore.execute(query)
        }
    
//    
//    
//    func startHeartRateMonitoring() {
//           requestAuthorization()
//           startAnchoredObjectQuery()
//       }
//    
//    func startAnchoredObjectQuery() {
//        print("Starting anchored object query for heart rate")
//        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
//        
//        // Create the anchored object query
//        heartRateQuery = HKAnchoredObjectQuery(
//            type: heartRateType,
//            predicate: nil,
//            anchor: anchor,
//            limit: HKObjectQueryNoLimit
//        ) { query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil in
//            if let error = errorOrNil {
//                print("Anchored object query error: \(error.localizedDescription)")
//                return
//            }
//
//            guard let samples = samplesOrNil else {
//                print("Anchored object query returned nil samples.")
//                return
//            }
//            
//            // Process the heart rate samples returned by the query
//            for sample in samples {
//                guard let quantitySample = sample as? HKQuantitySample else { continue }
//                
//                // Extract heart rate value from the sample
//                let heartRateValue = quantitySample.quantity.doubleValue(for: HKUnit(from: "count/min"))
//                
//                // Handle the heart rate value as needed
//                // For example, append it to the heartRate array
//                DispatchQueue.main.async {
//                    self.heartRate.append(heartRateValue)
//                }
//            }
//            
//            // Update the anchor for the next query iteration
//            // This ensures that the query continues from where it left off
//            self.anchor = newAnchor
//        }
//        
//        // Execute the query only if isDetecting is true
//        if isDetecting {
//            healthStore.execute(heartRateQuery!)
//        }
//    }
//
//
//    func requestAuthorization() {
//        print("Requesting authorization for heart rate")
//        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
//        healthStore.requestAuthorization(toShare: [], read: [heartRateType]) { success, error in
//            if success {
//                print("Authorization granted for heart rate")
//                self.startHeartRateMonitoring() // Call startHeartRateMonitoring here
//            } else {
//                print("Failed to request authorization for heart rate: \(error?.localizedDescription ?? "Unknown error")")
//            }
//        }
//    }

        
    
    
    
    //==============================

    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        requestAuthorization()

        // Inside the makeUIView method
        heartRateQueryTimer = Timer.scheduledTimer(withTimeInterval: heartRateQueryInterval, repeats: true) { [self] _ in
            self.fetchLatestHeartRate { heartRate in
                DispatchQueue.main.async {
                    self.heartRate.append(heartRate)
                }
            }
        }

//        startHeartRateMonitoring()

        
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
        Coordinator(detectedObjects: $detectedObjects, pushModel: pushModel, sitModel: sitModel, isDetecting: $isDetecting, selectedExercise: $selectedExercise, exerciseList: $exerciseList, exerciseCountList: $exerciseCountList, restTime: $restTime, mod: $mod, isFinished: $isFinished, isStop: $isStop, heartRate: $heartRate)
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
        @Binding var heartRate: [Double]
        
        
        init(detectedObjects: Binding<[String]>, pushModel: VNCoreMLModel, sitModel: VNCoreMLModel, isDetecting: Binding<Bool>, selectedExercise: Binding<String?>, exerciseList: Binding<[String]>, exerciseCountList: Binding<[Int]>, restTime: Binding<Int>, mod: Binding<String?>, isFinished: Binding<Bool>, isStop: Binding<Bool>, heartRate: Binding<[Double]>) {
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
            self._heartRate = heartRate
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
                                if (restTime > 0 && exerciseList.count >= 2 && exerciseCount < exerciseList.count){
                                    isStop = true
                                    isDetecting = false
                                }
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



