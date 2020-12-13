//
//  UI.swift
//  Weather
//
//  Created by Sylvie on 20.10.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


extension ViewController{
    func initGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        previewView.addGestureRecognizer(tap)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))
        
        //pinch to zoom, unused
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        
        longPress.minimumPressDuration = 0.0
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        upSwipe.direction = .up
        downSwipe.direction = .down
        
        previewView.addGestureRecognizer(leftSwipe)
        previewView.addGestureRecognizer(rightSwipe)
        previewView.addGestureRecognizer(upSwipe)
        previewView.addGestureRecognizer(downSwipe)
        //self.view.addGestureRecognizer(pinch)
        captureView.isUserInteractionEnabled = true
        captureView.addGestureRecognizer(longPress)
        
    }
    
    
    //pinch to zoom
    @objc func pinch(_ pinch: UIPinchGestureRecognizer) {
        var device:AVCaptureDevice = backCamera
        var vZoomFactor = pinch.scale
        //print(pinch.scale)
        if ((zoomLevel + (pinch.scale - lastZoom)*0.2) > 1.0 && (zoomLevel + (pinch.scale - lastZoom)*0.2) <=  backCamera.activeFormat.videoMaxZoomFactor/2){
            zoomLevel = zoomLevel + (pinch.scale - lastZoom)*0.2
        }
        
        var error:NSError!
        
        do{
            try device.lockForConfiguration()
            defer {device.unlockForConfiguration()}
            
            
            if (zoomLevel <= device.activeFormat.videoMaxZoomFactor/2){
                device.videoZoomFactor = max(1.0, min(zoomLevel,device.activeFormat.videoMaxZoomFactor/3))
            }else{
                NSLog("Unable to set videoZoom: (max %f, asked %f)", device.activeFormat.videoMaxZoomFactor, vZoomFactor);
            }
        }catch error as NSError{
            NSLog("Unable to set videoZoom: %@", error.localizedDescription);
        }catch _{
        }
    }
    
    
    @objc func handlePress(_ sender:UILongPressGestureRecognizer){
        switch uiState{
        case .capture:
            if sender.state == .began{
                print("began")
                captureView.state = .overlay
            }
            if sender.state == .changed{
                let newLocation = sender.location(in: self.view)
                if location == nil{
                    location = sender.location(in: self.view)
                }
                
                if abs(newLocation.x-location!.x)>20 || abs(newLocation.y-location!.y)>20{
                    let vel = CGPoint(x: newLocation.x-location!.x, y: newLocation.y-location!.y)
                    if getDirection(vel:vel) == .down {
                        captureView.state = .save
                    } else if getDirection(vel:vel) == .up{
                        captureView.state = .discard
                    }
                    location = newLocation
                }
            }
            
            if sender.state == .ended || sender.state == .cancelled{
                print("ended")
                // handle end of pressing
                if captureView.state == .save{
                    captureView.state = .saved
                    savePhoto()
                }else if captureView.state == .discard{
                    captureView.state = .discarded
                    discardPhoto()
                }
                else{
                    captureView.state = .idle
                }
                location = nil
                dataView.isHidden = false
                buttonView.isHidden = false
            }
            break
        default:
            return
        }
    }
    
    
    @objc func handleSwipe(_ sender:UISwipeGestureRecognizer){
        print("swiped")
        switch uiState{
        case .preview:
            //toggle camera
            toggleCamera()
            break
        default:
            return
        }
    }
    
    func getDirection(vel:CGPoint) -> UISwipeGestureRecognizer.Direction{
        if orientation == .up {
            if vel.y>0 && abs(vel.y)>abs(vel.x){
                print("down")
                return .down
            } else if vel.y<0 && abs(vel.y)>abs(vel.x){
                print("up")
                return .up
            }
        }
        
        else if orientation == .down {
            if vel.y<0 && abs(vel.y)>abs(vel.x){
                print("down")
                return .down
            }else if vel.y>0 && abs(vel.y)>abs(vel.x){
                print("up")
                return .up
            }
        }
        
        else if orientation == .left {
            if vel.x<0 && abs(vel.x)>abs(vel.y){
                print("down")
                return .down
            }else if vel.x>0 && abs(vel.x)>abs(vel.y){
                print("up")
                return .up
            }
        }
        
        else if orientation == .right {
            if vel.x>0 && abs(vel.x)>abs(vel.y){
                print("down")
                return .down
            }else if vel.x<0 && abs(vel.x)>abs(vel.y){
                print("up")
                return .up
            }
        }
        return .left
    }
    
    
    func getActualDirection(direction: UISwipeGestureRecognizer.Direction, val: CGFloat) -> UISwipeGestureRecognizer.Direction{
        if val == .pi {
            switch direction{
            case .up:
                return .down
            case .left:
                return .right
            case .right:
                return .left
            default:
                return .up
            }
            
        }
        else if val == -.pi/2 {
            switch direction{
            case .up:
                return .left
            case .left:
                return .down
            case .right:
                return .up
            default:
                return .right
            }
        }
        
        else if val == .pi/2 {
            switch direction{
            case .up:
                return .right
            case .left:
                return .up
            case .right:
                return .down
            default:
                return .left
            }
        }
        
        else{
            switch direction{
            case .up:
                return .up
            case .left:
                return .left
            case .right:
                return .right
            default:
                return .down
            }
        }
        
    }
    
    func toggleCamera() {
        group.notify(queue: .main) {
            if self.cameraMode == .back {
                self.cameraMode = .front
                print("camera switched: front")
            } else{
                self.cameraMode = .back
                print("camera switched: back")
            }
            
        }
        
    }
    
    func savePhoto(){
        print("saved")
        if thisResources != nil{
            saveImage()
        }
        else {
            captureState = .save
        }
    }
    
    func discardPhoto(){
        print("discard")
        if thisResources != nil{
            discardImage()
        }else {
            captureState = .discard
        }
    }
    
    @objc func handleTap(_ sender:UITapGestureRecognizer) {
        if uiState == .preview && frames.count>0{
            
            previewView.isHidden = true
            captureView.image = previewView.image
            uiState = .capture
            buttonView.isHidden = true
            dataView.isHidden = true
            newImage()
            //startOrientationUpdate()
            DispatchQueue.main.async {
                self.view.fadeOut(duration: 0.1, completion: {
                    (finished: Bool) -> Void in
                    self.view.fadeIn(duration: 0.1, completion: {_ in
                        self.createAssets()
                    })
                    
                })
            }
        }
    }
    
    
}
