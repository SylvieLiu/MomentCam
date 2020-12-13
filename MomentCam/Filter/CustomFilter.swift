//
//  Warp.swift
//  Weather
//
//  Created by Sylvie on 23.09.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//

import Foundation
import CoreImage

class CustomFilter: CIFilter {
    
    private let warpKernel = try? CIWarpKernel(functionName: "warp", fromMetalLibraryData: MetalLib.data)
    private let colorRGBKernel = try? CIKernel(functionName: "colorRGB", fromMetalLibraryData: MetalLib.data)
    
    func colorRGB(_ input:CIImage) -> CIImage{
        let arguments = [input, temperature] as [Any]
        
        let callback: CIKernelROICallback = {
            (index, rect) in
            return rect
        }
        
        if let outputImage = colorRGBKernel!.apply(extent: input.extent, roiCallback:callback, arguments: arguments){
            return outputImage
        }else{
            return input
        }
        
    }
    
    
    func warp(_ input:CIImage) -> CIImage{
        let radius = 200
        let force = intensity
        let extent = CIVector(x: input.extent.width, y: input.extent.height) as Any
        
        let random1 = CIVector(x: CGFloat.random(in: -0.02...0.02), y: CGFloat.random(in: -0.02...0.02))
        let random2 = CIVector(x: CGFloat.random(in: -0.02...0.02), y: CGFloat.random(in: -0.02...0.02))
        let random3 = CIVector(x: CGFloat.random(in: -0.02...0.02), y: CGFloat.random(in: -0.02...0.02))
        let random4 = CIVector(x: CGFloat.random(in: -0.02...0.02), y: CGFloat.random(in: -0.02...0.02))
        direction1 = CIVector(x:direction1.x+random1.x, y: direction1.y+random1.y)
        direction2 = CIVector(x:direction2.x+random2.x, y: direction2.y+random2.y)
        direction3 = CIVector(x:direction3.x+random3.x, y: direction3.y+random3.y)
        direction4 = CIVector(x:direction4.x+random4.x, y: direction4.y+random4.y)
        
        let arguments = [extent, direction1, direction2, direction3, direction4, intensity*intensity] as [Any]
        
        let callback: CIKernelROICallback = {
            (index, rect) in
            return rect
        }
        
        if let outputImage = warpKernel!.apply(extent: input.extent, roiCallback:callback, image: input,arguments: arguments){
            return outputImage
        }else{
            return input
        }
    }
}

class MetalLib {
    private static var url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
    static var data = try! Data(contentsOf: url)
}

