//
//  Camera.swift
//  Environment Camera
//
//  Created by Sylvie on 14.08.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//
import UIKit
import AVFoundation
import CoreImage
import Photos

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate{
    
    func cameraInit(){
        openCamera()
    }
    
    // MARK:-  start session
    
    func startCaptureSession() {
        uiState = .preview
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            startCapture = true
            fadeInView.fadeOut(duration: 0.2)
        }
        
        
        if AVCaptureMultiCamSession.isMultiCamSupported{
            emotionTrue = true
            emotionButton.setImage( UIImage.init(named: "emotion_on"), for: .normal)
            session = multiSession
            session.beginConfiguration()
            configureDevice(cameraPosition: .back, captureOutput: backCameraVideoDataOutput, framerate: 20)
            configureDevice(cameraPosition: .front, captureOutput: frontCameraVideoDataOutput, framerate: 10)
            session.commitConfiguration()
        }else{
            if cameraMode == .front{
                session = AVCaptureSession()
                session.beginConfiguration()
                configureDevice(cameraPosition: .front, captureOutput: frontCameraVideoDataOutput, framerate: 10)
                session.commitConfiguration()
                emotionTrue = true
                emotionButton.setImage( UIImage.init(named: "emotion_on"), for: .normal)
                dataView.circleView.updateValues()
                
                
            }else{
                session = AVCaptureSession()
                session.beginConfiguration()
                configureDevice(cameraPosition: .back, captureOutput: backCameraVideoDataOutput, framerate: 20)
                session.commitConfiguration()
                emotionTrue = false
                emotionButton.setImage( UIImage.init(named: "emotion_off"), for: .normal)
                dataView.circleView.updateValues()
            }
        }
        
        session.startRunning()
        
    }
    
    func configureDeviceSingle(cameraPosition: AVCaptureDevice.Position, captureOutput: AVCaptureVideoDataOutput, framerate: Double) {
        //let input = try! AVCaptureDeviceInput(device: device)
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        
        
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: cameraPosition){
            do {
                let cameraInput = try AVCaptureDeviceInput(device: device)
                session.addInput(cameraInput)
            } catch {
                print("camera input error: \(error)")
            }
        }
        
        if session.canAddOutput(captureOutput) {
            session.addOutput(captureOutput)
            captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        }
    }
    
    
    
    func configureDevice(cameraPosition: AVCaptureDevice.Position, captureOutput: AVCaptureVideoDataOutput, framerate: Double) {
        //let input = try! AVCaptureDeviceInput(device: device)
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        
        device.set(frameRate: framerate)
        
        if session.canAddInput(input) {
            session.addInputWithNoConnections(input)
        }
        
        captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        captureOutput.setSampleBufferDelegate(self, queue: outputQueue)
        if session.canAddOutput(captureOutput) {
            session.addOutputWithNoConnections(captureOutput)
            //session.addOutput(captureOutput)
        }
        
        let port = input.ports(for: .video, sourceDeviceType: device.deviceType, sourceDevicePosition: device.position)
        let connection = AVCaptureConnection(inputPorts: port, output: captureOutput)
        connection.videoOrientation = .portrait
        
        if session.canAddConnection(connection) {
            session.addConnection(connection)
        }
    }
    
    
    
    
    //MARK: - captureOutput
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // You just dropped a frame!
        //print("dropped!")
        var mode: CMAttachmentMode = 0
        let reason = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_DroppedFrameReason, attachmentModeOut: &mode)
        //print("reason \(String(describing: reason))")
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        
        connection.videoOrientation = .portrait
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        var cameraImage = CIImage(cvImageBuffer: pixelBuffer!)
        
        if cameraMode == .front {
            //cameraImage = cameraImage.oriented(.upMirrored)
            videoOutput = frontCameraVideoDataOutput
            
        } else if cameraMode == .back{
            //cameraImage = cameraImage.oriented(.up)
            videoOutput = backCameraVideoDataOutput
        }
        
        
        if captureOutput == backCameraVideoDataOutput {
            cameraImage = cameraImage.oriented(.up)
            
            if cameraMode == .back{
                let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
                var outputImage: UIImage
                
                if canAddFilter == true {
                    outputImage = filteredImage(cameraImage)
                    let thisBuffer = buffer(outputImage)
                    if startCapture == true{
                        buffers.append(thisBuffer!)
                        frames.append(outputImage)
                        timestamps.append(timestamp)
                    }
                }else{
                    outputImage = convertCIImagetoUIimage(cmage: cameraImage)
                }
                
                DispatchQueue.main.async {
                    if uiState == .preview {
                        previewView.isHidden = false
                        previewView.image = outputImage
                    }
                }
            }
        }
        else if captureOutput == frontCameraVideoDataOutput {
            cameraImage = cameraImage.oriented(.upMirrored)
            
            if cameraMode == .front {
                
                let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
                var outputImage: UIImage
                
                if canAddFilter == true {
                    outputImage = filteredImage(cameraImage)
                    let thisBuffer = buffer(outputImage)
                    if startCapture == true{
                        buffers.append(thisBuffer!)
                        frames.append(outputImage)
                        timestamps.append(timestamp)
                    }
                }else{
                    outputImage = convertCIImagetoUIimage(cmage: cameraImage)
                }
                
                DispatchQueue.main.async {
                    if uiState == .preview {
                        previewView.isHidden = false
                        previewView.image = outputImage
                    }
                }
            }
            
            DispatchQueue.main.async {
                
                let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
                    if canDectectFace == false {
                        canDectectFace = true
                    }
                }
                
                if canDectectFace == true {
                    faceDetection.detectFace(cameraImage)
                    canDectectFace = false
                }
                
                //previewView2.image = self.convertCIImagetoUIimage(cmage: cameraImage)
            }
        }
    }
    
    
    
    
    // MARK:-  live photo
    func newImage(){
        if frames.count > 0 {
            imageQueue.insert(frames, at: 0)
            timestampQueue.insert(timestamps, at: 0)
            bufferQueue.insert(buffers, at: 0)
        }else{
            return
        }
    }
    
    func createAssets(){
        for i in (0..<imageQueue.count).reversed() {
            let assetwriter = assetWriter()
            assetwriter.thisFrames = imageQueue[i]
            assetwriter.thisTimestamps = timestampQueue[i]
            assetwriter.thisBufferPool = bufferQueue[i]
            imageQueue.remove(at: i)
            timestampQueue.remove(at: i)
            bufferQueue.remove(at: i)
            assetwriter.makeVideoFromImage(thisRotation: rotation, thisOrientation: orientation)
        }
    }
    
    func buffer(_ image: UIImage) -> CVPixelBuffer? {
        let ciImage = CIImage(image: image)
        var pixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        let width:Int = Int(ciImage!.extent.width)
        let height:Int = Int(ciImage!.extent.height)
        CVPixelBufferCreate(kCFAllocatorDefault,width,height,kCVPixelFormatType_32BGRA,attrs,&pixelBuffer)
        CIContext().render(ciImage!, to: pixelBuffer!)
        return pixelBuffer
    }
    
    func generateLivePhoto(){
        LivePhoto.generate(from: imageURL, videoURL: videoURL!, progress: { percent in }, completion: { livePhoto, resources in
            thisResources = resources
            do{
                try FileManager.default.removeItem(at: imageURL!)
                try FileManager.default.removeItem(at: videoURL!)
            }catch{
                print("error: \(error)")
            }
            
            if captureState == .save {
                self.saveImage()
                print("photo saved")
            }
            
            else if captureState == .discard {
                self.discardImage()
            }
        })
    }
    
    func discardImage(){
        do {
            try FileManager.default.removeItem(at: thisResources!.pairedImage)
            try FileManager.default.removeItem(at: thisResources!.pairedVideo)
            captureState = .idle
            //uiState = .preview
            thisResources = nil
        } catch {
            print("error: \(error)")
        }
    }
    
    func saveImage(){
        if (thisResources != nil) {
            LivePhoto.saveToLibrary(thisResources!, completion: { (success) -> Void in
                if success { // this will be equal to whatever value is set in this method call
                    print("live photo saved")
                } else {
                    print("saving photo error")
                }
            })
        }
        
        captureState = .idle
        //uiState = .preview
        thisResources = nil
    }
    
    
    // MARK:-  session
    
    func stopCaptureSession(){
        startCapture = false
        
        if let inputs = session.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                session.removeInput(input)
            }
        }
        session.stopRunning()
        
        clearData()
    }
    
    func clearData(){
        timestamps = []
        buffers = []
        frames = []
    }
    
    @objc func handleDismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func openCamera(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // the user has already authorized to access the camera.
            self.startCaptureSession()
            self.microphone.start()
            self.initLocationManager()
            
        case .notDetermined: // the user has not yet asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // if user has granted to access the camera.
                    print("the user has granted to access the camera")
                    
                    self.initLocationManager()
                    self.microphone.start()
                    
                    DispatchQueue.main.async {
                        self.startCaptureSession()
                        
                    }
                } else {
                    print("the user has not granted to access the camera")
                    self.handleDismiss()
                    
                }
            }
            
        default:
            print("something has wrong due to we can't access the camera.")
            self.handleDismiss()
        }
    }
}

extension AVCaptureDevice {
    func set(frameRate: Double) {
        guard let range = activeFormat.videoSupportedFrameRateRanges.first,
              range.minFrameRate...range.maxFrameRate ~= frameRate
        else {
            print("Requested FPS is not supported by the device's activeFormat !")
            return
        }
        
        do { try lockForConfiguration()
            activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
            activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
            
            unlockForConfiguration()
        } catch {
            print("LockForConfiguration failed with error: \(error.localizedDescription)")
        }
    }
}





