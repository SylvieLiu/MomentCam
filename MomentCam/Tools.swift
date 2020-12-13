//
//  Tools.swift
//  Weather
//
//  Created by Sylvie on 14.10.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//

import Foundation
import CoreImage
import UIKit
import CoreMotion

extension UIView {
    func fadeIn(duration: Double, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(duration: Double, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
    
    func rotate(duration: Double) {
            let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
            rotation.toValue = NSNumber(value: Double.pi)
            rotation.duration = duration
            rotation.isCumulative = false
            //rotation.repeatCount = Float.greatestFiniteMagnitude
            self.layer.add(rotation, forKey: "rotationAnimation")
        }
    
}


extension ViewController{
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    func convertCIImagetoUIimage(cmage:CIImage) -> UIImage {
        //let context:CIContext = CIContext.init(options: nil)
        guard let cgImage:CGImage = CIContext().createCGImage(cmage, from: cmage.extent) else {
            return frames.last!
        }
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }

    
    func convert(cmage:CGImage) -> UIImage
    {
        let image:UIImage = UIImage.init(cgImage: cmage)
        return image
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

extension URL {
    static func tempFile(withFileExtension fileExtension: String) -> URL {
        let fileName = "\(NSUUID().uuidString).\(fileExtension)"
        let filePathString = (NSTemporaryDirectory() as NSString).appendingPathComponent(fileName)
        return URL(fileURLWithPath: filePathString)
    }
}


extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


extension ViewController{
    // check orientation update with Accelerometer
    func startOrientationUpdate(){
        //motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.gyroUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: (OperationQueue.current)!, withHandler: {
            (accelerometerData, error) -> Void in

            if error == nil {
                self.outputAccelertionData((accelerometerData?.acceleration)!)
                //self.motionManager.stopAccelerometerUpdates()
            }
            else {
                print("\(error!)")
            }
        })
    }
    
    func outputAccelertionData(_ thisAcceleration: CMAcceleration){
       // print("acceleration", thisAcceleration)
        
        if acceleration != nil {
            //print(CMAcceleration(x: (thisAcceleration.x-acceleration!.x)*(-9.81), y: (thisAcceleration.y-acceleration!.y)*(-9.81), z: (thisAcceleration.z-acceleration!.z)*(-9.81)))
            lastAcceleration = CMAcceleration(x: (thisAcceleration.x-acceleration!.x)*(-9.81), y: (thisAcceleration.y-acceleration!.y)*(-9.81), z: (thisAcceleration.z-acceleration!.z)*(-9.81))
        }
        
        acceleration = thisAcceleration
        
        var thisRotation: CGFloat = 0
        var thisOrientation: CGImagePropertyOrientation = .up
        if thisAcceleration.x >= 0.75 {
            thisOrientation = .right
            thisRotation = .pi/2
        }
        else if thisAcceleration.x <= -0.75 {
            thisOrientation = .left
            thisRotation = -(.pi/2)
        }
        else if thisAcceleration.y <= -0.75 {
            thisOrientation = .up
            thisRotation = 0
        }
        else if thisAcceleration.y >= 0.75 {
            thisOrientation = .down
            thisRotation = .pi
        }
        //print("rotation", rotation)
        if rotation != thisRotation{
            rotation = thisRotation
            orientation = thisOrientation
        }
        
    }
    
    func stopOrientationUpdate(){
        self.motionManager.stopAccelerometerUpdates()
    }
}
