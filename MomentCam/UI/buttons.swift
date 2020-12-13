//
//  buttonView.swift
//  MomentCam
//
//  Created by Sylvie on 09.12.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//

import Foundation
import UIKit

// buttons to toggle data source on and off

extension ViewController{
    func buttonSetup(){
        buttonView.frame = CGRect(x: UIScreen.main.bounds.midX-80, y: dataView.ringView.frame.minY+15, width: 180, height: 50)
        soundButton.frame = CGRect(x: buttonView.frame.width/2-30, y: buttonView.frame.height/2-30, width: 60, height: 60)
        /*
        if soundTrue == true{
            soundButton.setImage( UIImage.init(named: "sound_on"), for: .normal)
        }else{
            soundButton.setImage( UIImage.init(named: "sound_off"), for: .normal)
        }
        
        if emotionTrue == true{
            emotionButton.setImage( UIImage.init(named: "emotion_on"), for: .normal)
        }else{
            emotionButton.setImage( UIImage.init(named: "emotion_off"), for: .normal)
        }
        
        if weatherTrue == true{
            weatherButton.setImage( UIImage.init(named: "weather_on"), for: .normal)
        }else{
            weatherButton.setImage( UIImage.init(named: "weather_off"), for: .normal)
        }*/
        soundButton.addTarget(self, action: #selector(soundButtonTapped(_:)), for: .touchUpInside)
        buttonView.addSubview(soundButton)
        soundButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        weatherButton.frame = CGRect(x: 0, y: buttonView.frame.height/2-30, width: 60, height: 60)
        //weatherButton.setImage( UIImage.init(named: "weather_on"), for: .normal)
        weatherButton.addTarget(self, action: #selector(weatherButtonTapped(_:)), for: .touchUpInside)
        buttonView.addSubview(weatherButton)
        weatherButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        emotionButton.frame = CGRect(x: buttonView.frame.width-60, y: buttonView.frame.height/2-30, width: 60, height: 60)
        //emotionButton.setImage( UIImage.init(named: "emotion_on"), for: .normal)
        emotionButton.addTarget(self, action: #selector(emotionButtonTapped(_:)), for: .touchUpInside)
        buttonView.addSubview(emotionButton)
        emotionButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
    @objc func soundButtonTapped(_ sender: UIButton){
        print("button pressed")
        if soundTrue != nil{
            if soundButton.currentImage == UIImage.init(named: "sound_on") {
                soundTrue = false
                soundButton.setImage( UIImage.init(named: "sound_off"), for: .normal)
                
            } else{
                soundTrue = true
                soundButton.setImage( UIImage.init(named: "sound_on"), for: .normal)
            }
            dataView.circleView.updateValues()
        }
    }
    
    
    @objc func weatherButtonTapped(_ sender: UIButton){
        if weatherTrue != nil{
            if weatherButton.currentImage == UIImage.init(named: "weather_on") {
                weatherTrue = false
                weatherButton.setImage( UIImage.init(named: "weather_off"), for: .normal)
            } else{
                weatherTrue = true
                weatherButton.setImage( UIImage.init(named: "weather_on"), for: .normal)
            }
            dataView.circleView.updateValues()
        }
    }
    
    @objc func emotionButtonTapped(_ sender: UIButton){
            if multiCapture == false && cameraMode == .back{
                //button disabled
                self.present(alert, animated: true, completion: nil)
                print("button inactive")
                
            }else{
                if emotionButton.currentImage == UIImage.init(named: "emotion_on") {
                    emotionTrue = false
                    emotionButton.setImage( UIImage.init(named: "emotion_off"), for: .normal)
                } else{
                    
                    emotionTrue = true
                    emotionButton.setImage( UIImage.init(named: "emotion_on"), for: .normal)
                }
                dataView.circleView.updateValues()
            }
    }
}
