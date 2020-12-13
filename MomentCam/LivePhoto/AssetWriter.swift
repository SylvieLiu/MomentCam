//
//  AssetWriter.swift
//  Weather
//
//  Created by Sylvie on 19.10.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreImage
import Photos

class assetWriter{
    var assetWriter: AVAssetWriter?
    var assetWriterInput: AVAssetWriterInput?
    var adpater: AVAssetWriterInputPixelBufferAdaptor?
    var thisFrames: [UIImage] = []
    var thisTimestamps: [Double] = []
    var thisBufferPool: [CVPixelBuffer] = []
    
    
    //generate live photo
    func makeVideoFromImage(thisRotation: CGFloat, thisOrientation:CGImagePropertyOrientation){
        //create cover image
        var ciimage = CIImage(image: thisFrames.last!)!
        let newCIimage = ciimage.oriented(thisOrientation)
        
        imageURL = URL.tempFile(withFileExtension: "jpeg")
        do {
            try CIContext().writeJPEGRepresentation(of: newCIimage, to: imageURL!, colorSpace: newCIimage.colorSpace!)
        } catch {
            print("error: \(error)")
        }
        
        //init asset writer
        videoURL = URL.tempFile(withFileExtension: "mov")
        let writer = try! AVAssetWriter(outputURL: videoURL!, fileType: .mov)
        let settings = videoOutput!.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
        //let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: ciimage.extent.width, AVVideoHeightKey: ciimage.extent.height])
        input.mediaTimeScale = CMTimeScale(bitPattern: 600)
        input.expectsMediaDataInRealTime = false
        input.transform = CGAffineTransform(rotationAngle: thisRotation)
        let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
        if writer.canAdd(input) {
            writer.add(input)
        }
        
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        
        assetWriter = writer
        assetWriterInput = input
        adpater = adapter
        
        
        //add data -> need improvement
        for i in 0..<thisFrames.count-1 {
            while assetWriterInput!.isReadyForMoreMediaData == false {
                print("runloop")
                let maxDate = Date(timeIntervalSinceNow: 0.1)
                RunLoop.current.run(until: maxDate)
            }
            
            if assetWriterInput!.isReadyForMoreMediaData == true && assetWriter!.status != .failed{
                let time = CMTime(seconds: Double(i)*0.1, preferredTimescale: CMTimeScale(600))
                let thisBuffer = buffer(thisFrames[i])!
                //adpater?.append(thisBufferPool[i], withPresentationTime: time)
                adpater?.append(thisBuffer, withPresentationTime: time)
                //usleep(useconds_t(10000) )
            } else {
                print("error", assetWriterInput?.isReadyForMoreMediaData)
                uiState = .preview
                return
            }
        }
        
        //finish recording
        assetWriterInput?.markAsFinished()
        //----------- add completionhandeler
        assetWriter?.finishWriting {
            vc.generateLivePhoto()
        }
    }
    
    // convert uiimage into buffer
    func buffer(_ image: UIImage) -> CVPixelBuffer? {
        let ciImage = CIImage(image: image)
        var pixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        let width:Int = Int(ciImage!.extent.width)
        let height:Int = Int(ciImage!.extent.height)
        //print("width", width, height)
        CVPixelBufferCreate(kCFAllocatorDefault,width,height,kCVPixelFormatType_32BGRA,attrs,&pixelBuffer)
        CIContext().render(ciImage!, to: pixelBuffer!)
        return pixelBuffer
    }
    
    
}
