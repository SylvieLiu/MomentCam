//
//  Filter.swift
//  Weather
//
//  Created by Sylvie on 25.10.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//

import UIKit
import Foundation
import CoreImage
import Photos

struct Summer{
    var highlight:CGFloat = 0.7-0.4*clouds //0.7 - 0.3
    var shadow:CGFloat = 0.3+0.3*clouds //0.3 - 0.6
    var contrast:CGFloat = 1.03+0.1*clouds //1.03 - 1.33
    var vib:CGFloat = 0.3-1.3*clouds //0.3 - -1
    var temp:CGFloat = 30000
    var tint:CGFloat = -20
    var saturation:CGFloat = 1-0.4*clouds //1 - 0.6
}

struct Winter{
    var highlight:CGFloat = 0.3
    var shadow:CGFloat = 0.3-0.3*clouds //0.3 - 0.6
    var contrast:CGFloat = 1.03-0.3*clouds //1.03 - 1.3
    var vib:CGFloat = 0.3-1.3*clouds //0.3 - -1
    var temp:CGFloat = 7000
    var tint:CGFloat = 0
    var saturation:CGFloat = 1-0.4*clouds //1 - 0.6
}


extension ViewController{
    //convert data into filter intensity
    func updateValue(){
        var summer = Summer()
        summer.highlight = 0.7-0.4*clouds //0.7 - 0.3
        summer.shadow = 0.3+0.3*clouds //0.3 - 0.6
        summer.contrast = 1.03+0.1*clouds //1.03 - 1.33
        summer.vib = 0.3-1*clouds //0.3 - -0.7
        summer.temp = 30000
        summer.tint = -20
        summer.saturation = 1.0-0.3*clouds //1 - 0.6
        
        var winter = Winter()
        winter.highlight = 0.3
        winter.shadow = 0.3-0.3*clouds //0.3 - 0.6
        winter.contrast = 1.03-0.1*clouds //1.03 - 1.3
        winter.vib = 0.3-1*clouds //0.3 - -0.7
        winter.temp = 7000
        winter.tint = 0
        winter.saturation = 1.0-0.3*clouds //1 - 0.6
        
        if weatherTrue == true {
            highlight = temperature*summer.highlight + (1-temperature)*winter.highlight
            shadow = temperature*summer.shadow + (1-temperature)*winter.shadow
            contrast = temperature*summer.contrast + (1-temperature)*winter.contrast
            vib = temperature*summer.vib + (1-temperature)*winter.vib
            temp = temperature*summer.temp + (1-temperature)*winter.temp
            tint = temperature*summer.tint + (1-temperature)*winter.tint
            saturation = temperature*summer.saturation + (1-temperature)*winter.saturation
        } else{
            contrast = 1.0
            saturation = 1.0
        }
        
        if emotionTrue == true  {
            contrast = (1 + anger*0.3 + suprise*0.05)*contrast
            saturation = max(0.0, min(saturation + (happiness*0.5 + sadness),1.5))
        }
    }
    
    
    func filteredImage(_ inputImage: CIImage) -> UIImage{
        var outputImage: CIImage
        outputImage = inputImage
        
        updateValue()
        
        if weatherTrue == true {
            outputImage = highlightShadow(outputImage)
            outputImage = warmthFilter(outputImage)
            outputImage = vibrance(outputImage)
            outputImage = colorMatrix(outputImage, r: -0.02*(1-temperature), g: -0.015*(1-temperature), b: 0.02*(1-temperature))
        }
        
        if soundTrue == true {
            outputImage = warp(outputImage)
            let gradientImage = gradient(outputImage)
            outputImage = CIMix(gradientImage, bgImage: outputImage, val:intensity)
        }
        
        outputImage = colorAdjust(outputImage)
        
        if soundTrue == true {
            var outlineLayer = outputImage
            outlineLayer = blur(outlineLayer)
            outlineLayer = outline(outlineLayer)
            outputImage = merge(bottom: outputImage, top: outlineLayer, blendMode: "CISourceOverCompositing")
        }
        
        
        
        //movement RGB filter effect
        if lastFrames.count<3 {
            lastFrames.append(outputImage)
        }else{
            lastFrames.remove(at: 0)
            lastFrames.append(outputImage)
            if (abs(lastAcceleration.x)>1 || abs(lastAcceleration.y)>1 || abs(lastAcceleration.z)>1){
                let img1 = colorMatrix(lastFrames[0], r: 0,g: -1,b: -1)
                let img2 = colorMatrix(lastFrames[1],r: -1.0,g: -1.0,b: 0)
                let img3 = colorMatrix(lastFrames[2],r: -1.0,g: 0,b: -1.0)
                outputImage = merge(bottom: img1, top: img2, blendMode: "CIMaximumCompositing")
                outputImage = merge(bottom: outputImage, top: img3, blendMode: "CIMaximumCompositing")
            }
        }
        
        //crop the image to 4:3 ratio
        outputImage = cropImage(outputImage)
        return convertCIImagetoUIimage(cmage: outputImage)
    }
    
    
    func cropImage(_ image: CIImage) -> CIImage{
        var ciimage = image
        if (image.extent.width>image.extent.height){
            let borderWidthX = image.extent.width.truncatingRemainder(dividingBy: 120)
            let borderWidthY = image.extent.height.truncatingRemainder(dividingBy: 120)
            
            let targetWidth = (image.extent.height-borderWidthX)*4/3
            let targetHeight = (image.extent.height-borderWidthY)
            
            ciimage = image.cropped(to: CGRect(x: image.extent.midX-targetWidth/2, y: image.extent.midY-targetHeight/2+borderWidthY/2, width: targetWidth, height: targetHeight-borderWidthY))
        } else{
            let borderWidthX = image.extent.width.truncatingRemainder(dividingBy: 120)
            let borderWidthY = image.extent.height.truncatingRemainder(dividingBy: 120)
            
            let targetWidth = (image.extent.width-borderWidthX)
            let targetHeight = (image.extent.width-borderWidthY)*4/3
            
            ciimage = image.cropped(to: CGRect(x: image.extent.midX-targetWidth/2+borderWidthX/2, y: image.extent.midY-targetHeight/2, width: targetWidth-borderWidthX, height: targetHeight))
        }
        return ciimage
    }
    
    
    func CIMix(_ image: CIImage, bgImage:CIImage, val:CGFloat) -> CIImage{
        let filter = CIFilter(name:"CIMix")
        filter!.setValue(image, forKey: "inputImage")
        filter!.setValue(bgImage, forKey: "inputBackgroundImage")
        filter!.setValue(val, forKey: "inputAmount")
        let ciimage = filter!.outputImage!
        return ciimage
    }
    
    func blur(_ image: CIImage) -> CIImage{
        let filter = CIFilter(name:"CIGaussianBlur")
        filter!.setValue(image, forKey: "inputImage")
        filter!.setValue(2, forKey: "inputRadius")
        let ciimage = filter!.outputImage!
        return ciimage
    }
    
    func outline(_ image: CIImage) -> CIImage{
        let filter = CIFilter(name:"CILineOverlay")
        filter!.setValue(image, forKey: "inputImage")
        filter!.setValue(1.0, forKey: "inputNRNoiseLevel")
        filter!.setValue(0.7, forKey: "inputNRSharpness")
        filter!.setValue(min(intensity,1.5), forKey: "inputEdgeIntensity")
        filter!.setValue(0.2, forKey: "inputThreshold")
        filter!.setValue(50, forKey: "inputContrast")
        
        // filter!.setValue(2, forKey: "inputAmount")
        let ciimage = filter!.outputImage!
        return ciimage
    }
    
    
    func colorMatrix(_ image: CIImage, r:CGFloat, g:CGFloat, b:CGFloat) -> CIImage{
        let filter = CIFilter(name:"CIColorMatrix")
        
        let bias = CIVector(x: r, y: g, z: b, w: 0)
        filter!.setValue(bias, forKey: "inputBiasVector")
        filter!.setValue(image, forKey: "inputImage")
        let ciimage = filter!.outputImage!
        return ciimage
    }
    
    func gradient(_ image: CIImage) -> CIImage{
        var gradientImage:CIImage
        if (clouds>=0.5){
            gradientImage = CIImage(image: UIImage(named:"gradient2.png")!)!
        } else{
            gradientImage = CIImage(image: UIImage(named:"gradient.png")!)!
        }
        
        let filter = CIFilter(name: "CIColorMap", parameters: ["inputImage":image, "inputGradientImage":gradientImage])
        let ciimage = filter!.outputImage!
        
        return ciimage
    }
    
    func warp(_ image: CIImage) -> CIImage{
        let ciimage = CustomFilter().warp(image)
        return ciimage
    }
    
    func highlightShadow(_ cameraImage: CIImage) -> CIImage{
        let filter = CIFilter(name:"CIHighlightShadowAdjust")
        filter!.setValue(shadow, forKey: "inputShadowAmount") // -1 - 1
        filter!.setValue(highlight, forKey: "inputHighlightAmount") // 0-1
        filter!.setValue(cameraImage, forKey: kCIInputImageKey)
        let ciimage = filter!.outputImage!
        return ciimage
    }
    
    func colorAdjust(_ cameraImage: CIImage) -> CIImage{
        let colorFilter = CIFilter(name:"CIColorControls")
        colorFilter!.setValue(contrast, forKey: "inputContrast")
        colorFilter!.setValue(saturation, forKey: "inputSaturation")
        colorFilter!.setValue(cameraImage, forKey: kCIInputImageKey)
        let ciimage = colorFilter!.outputImage!
        return ciimage
    }
    
    func vibrance(_ cameraImage: CIImage) -> CIImage{
        //weather
        let vibranceFilter = CIFilter(name:"CIVibrance")
        vibranceFilter!.setValue(vib, forKey: kCIInputAmountKey)
        vibranceFilter!.setValue(cameraImage, forKey: kCIInputImageKey)
        let ciimage = vibranceFilter!.outputImage!
        return ciimage
    }
    
    func merge(bottom:CIImage, top:CIImage, blendMode:String)->CIImage{
        let combined_image = CIFilter(name: blendMode, parameters: ["inputImage":top, "inputBackgroundImage":bottom])
        return (combined_image?.outputImage)!
    }
    
    func warmthFilter(_ cameraImage: CIImage) -> CIImage{
        //temperature
        let value = normalizeValue(val: temperature, maxVal: 30, minVal: 0)
        let saturationFilter = CIFilter(name:"CITemperatureAndTint")
        saturationFilter!.setValue(cameraImage, forKey: kCIInputImageKey)
        let inputVector = CIVector(x: 10000, y: 0) // arbitrary values
        saturationFilter!.setValue(inputVector, forKey: "inputNeutral")
        let targetVector = CIVector(x: temp, y: tint) // arbitrary values -> 4000 - 9000
        //print("warmthFilter", temperature, 9000-value*5000)
        saturationFilter!.setValue(targetVector, forKey: "inputTargetNeutral")
        let ciimage = saturationFilter!.outputImage!
        return ciimage
    }
}

