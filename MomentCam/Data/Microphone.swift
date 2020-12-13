//
//  Camera.swift
//  Environment Camera
//
//  Created by Sylvie on 14.08.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class Microphone: ObservableObject {
    
    private var audioSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder
    private var timer: Timer?
    
    init() {
        audioRecorder = AVAudioRecorder()
        audioSession = AVAudioSession.sharedInstance()
        
        //check permission
        if audioSession.recordPermission != .granted {
            audioSession.requestRecordPermission { (isGranted) in
                if !isGranted {
                    DispatchQueue.main.async {
                        print("set off")
                        soundButton.setImage( UIImage.init(named: "sound_off"), for: .normal)
                    }
                    return
                }
                else{
                    soundTrue = true
                    DispatchQueue.main.async {
                        print("set")
                        soundButton.setImage( UIImage.init(named: "sound_on"), for: .normal)
                    }
                }
            }
        }else{
            soundTrue = true
            DispatchQueue.main.async {
                print("set")
                soundButton.setImage( UIImage.init(named: "sound_on"), for: .normal)
            }
        }
        
        
        //setup
        let url = URL(fileURLWithPath: "/dev/null", isDirectory: true)
        
        let recorderSettings: [String:Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recorderSettings)
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    func start() {
        audioRecorder.record()
        audioRecorder.isMeteringEnabled = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            self.audioRecorder.updateMeters()
            amplitude = CGFloat(self.audioRecorder.averagePower(forChannel: 0))
            if (intensity>0 && (vc.normalizeValue(val: amplitude, maxVal: 0, minVal: -40)) == 0){
                direction1 = CIVector(x: CGFloat.random(in: -0.4...0.4), y: CGFloat.random(in: -0.4...0.4))
                direction2 = CIVector(x: CGFloat.random(in: -0.4...0.4), y: CGFloat.random(in: -0.4...0.4))
                direction3 = CIVector(x: CGFloat.random(in: -0.4...0.4), y: CGFloat.random(in: -0.4...0.4))
                direction4 = CIVector(x: CGFloat.random(in: -0.4...0.4), y: CGFloat.random(in: -0.4...0.4))
            }
            intensity = vc.normalizeValue(val: amplitude, maxVal: 0, minVal: -40)
            
        })
    }
    
    func stop(){
        timer?.invalidate()
        audioRecorder.stop()
    }
}
