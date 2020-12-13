//
//  faceDetection.swift
//  FaceTracker
//
//  Created by Sylvie on 14.11.20.
//  Copyright © 2020 Anurag Ajwani. All rights reserved.
//

import Vision
import UIKit

class FaceDetection{
    var boundingBox:CGRect?
    var boundingBoxScreen:CGRect?
    var points:VNFaceLandmarkRegion2D?
    var thisImage:CIImage?
    var rotation: CGFloat?
    
    func detectFace(_ image: CIImage){
        thisImage = image
        let faceLandmarks = VNDetectFaceLandmarksRequest()
        let faceDetectionRequest = VNSequenceRequestHandler()
        try? faceDetectionRequest.perform([faceLandmarks], on: image)
        if let results = faceLandmarks.results as? [VNFaceObservation] {
            if !results.isEmpty {
                points = results[0].landmarks?.allPoints
                currentVal = points!.normalizedPoints
                self.updateVal()
                
            } else{
                print("no face")
            }
        }
    }
    
    func updateVal(){
        sadVal()
        angerVal()
    }
    
    
    func sadVal(){
        let middlePoint = CGPoint(x: (currentVal[27].x+currentVal[34].x)/2, y: (currentVal[27].y+currentVal[34].y)/2)
        let distance = CGPointDistance(from: middlePoint, to: currentVal[30])/CGPointDistance(from: middlePoint, to: currentVal[37])
        
        let thisSadness = -normalizeValue(val: distance, maxVal: smileRange[0], minVal: smileRange[1])
        let thisHappiness = 1-normalizeValue(val: distance, maxVal: smileRange[1], minVal: smileRange[2])
        
        if abs(sadness-thisSadness)>0.1{
            sadness = thisSadness
        }
        
        if abs(happiness-thisHappiness)>0.1{
            happiness = thisHappiness
        }
        //print("happiness", happiness, sadness)
        
    }
    
    func angerVal(){
        //0.08 - 0.11 - 0.16
        let distanceLeft = CGPointDistance(from: currentVal[1], to: currentVal[16])
        let distanceRight = CGPointDistance(from: currentVal[8], to: currentVal[22])
        let thisBrowEyeDistance = (distanceLeft+distanceRight)/2
        
        let thisAnger = 1 - normalizeValue(val: thisBrowEyeDistance, maxVal: browDefault, minVal: browDefault-0.03)
        let thisSuprise = -normalizeValue(val: thisBrowEyeDistance, maxVal: browDefault+0.03, minVal: browDefault)
        if abs(thisAnger-anger) > 0.1 {
            anger = thisAnger
        }
        
        if abs(thisSuprise-suprise) > 0.1 {
            suprise = thisSuprise
        }
    }
    
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    func normalizeValue(val:CGFloat, maxVal:CGFloat, minVal:CGFloat) -> CGFloat{
        var thisVal:CGFloat = val
        if thisVal>maxVal {
            thisVal = maxVal
        }
        
        if val<minVal {
            thisVal = minVal
        }
        let newVal: CGFloat = CGFloat((thisVal - minVal) / (maxVal - minVal))
        return newVal
    }
}




