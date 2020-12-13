//
//  OverlayView.swift
//  Weather
//
//  Created by Sylvie on 26.10.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//

import Foundation
import UIKit

class CircularView:UIView{
    let blue:UIColor = UIColor(red: 50/255, green: 178/255, blue: 214/255, alpha: 1.0)
    let pink:UIColor = UIColor(red: 229/255, green: 31/255, blue: 111/255, alpha: 1.0)
    let yellow:UIColor = UIColor(red: 243/255, green: 185/255, blue: 39/255, alpha: 1.0)
    let purple:UIColor = UIColor(red: 112/255, green: 61/255, blue: 163/255, alpha: 1.0)
    
    var r:CGFloat = 0.0
    var lineWidth:CGFloat = 0.0
    //var percents:[CGFloat] = [0.1,0.6,0.3]
    var percents:[CGFloat] = [0.0,0.0,0.0,0.0]
    
    //circular layers
    let weatherLayer = CAShapeLayer()
    let visionLayer = CAShapeLayer()
    let soundLayer = CAShapeLayer()
    let emotionLayer = CAShapeLayer()
    
    let weatherLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let visionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let soundLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let emotionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    
    init(frame: CGRect, width:CGFloat, label:Bool){
        super.init(frame: frame)
        lineWidth = width*UIScreen.main.bounds.width/375
        
        drawArch(color: purple, layer: visionLayer)
        drawArch(color: yellow, layer: emotionLayer)
        drawArch(color: pink, layer: soundLayer)
        drawArch(color: blue, layer: weatherLayer)
        
        
        if label {
            drawUILabel(color: purple, text:"Visual", textLabel: visionLabel)
            drawUILabel(color: pink, text:"Sound", textLabel: soundLabel)
            drawUILabel(color: blue, text:"Weather", textLabel: weatherLabel)
            drawUILabel(color: yellow, text:"Emotion", textLabel: emotionLabel)
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.updateValues()
        }
    }
    
    
    func updateValues(){
        let weatherVal = abs((temperature/25)-0.5)+abs((clouds/100)-0.5)
        let soundVal = intensity*2
        let emotionVal = (abs((happiness-sadness))+abs((anger-suprise)))
        
        
        let total = weatherVal+soundVal+emotionVal
        let partition = 0.68*(total)/4
        
        
        var soundPercent:CGFloat
        var weatherPercent:CGFloat
        var emotionPercent:CGFloat
        
        if soundTrue == true {
            soundPercent = soundVal/total*partition+0.08
            soundLabel.isHidden = false
        }else{
            soundPercent = 0
            soundLabel.isHidden = true
        }
        
        if emotionTrue == true {
            emotionPercent = emotionVal/total*partition+0.08
            emotionLabel.isHidden = false
        }else{
            emotionPercent = 0
            emotionLabel.isHidden = true
        }
        
        if weatherTrue == true {
            weatherPercent = weatherVal/total*partition+0.08
            weatherLabel.isHidden = false
        }else{
            weatherPercent = 0
            weatherLabel.isHidden = true
        }
        
        
        let visionPercent = 1.0 - weatherPercent - soundPercent - emotionPercent
        let thisPercents:[CGFloat] = [visionPercent,emotionPercent,soundPercent,weatherPercent]
        //print("thisPercents", thisPercents,weatherVal, soundVal)
        
        animation(startValues: [0.0,0.0], layer:visionLayer)
        animation(startValues: [percents[0],thisPercents[0]], layer:emotionLayer)
        animation(startValues: [percents[0]+percents[1],thisPercents[0]+thisPercents[1]], layer:soundLayer)
        animation(startValues: [percents[0]+percents[1]+percents[2],thisPercents[0]+thisPercents[1]+thisPercents[2]], layer:weatherLayer)
        
        
        textAnimation(layer: visionLabel.layer,values: [Double(percents[0]/2), Double(thisPercents[0]/2)])
        textAnimation(layer: emotionLabel.layer,values: [Double(percents[0]+percents[1]/2), Double(thisPercents[0]+thisPercents[1]/2)])
        textAnimation(layer: soundLabel.layer,values: [Double(percents[0]+percents[1]+percents[2]/2), Double(thisPercents[0]+thisPercents[1]+thisPercents[2]/2)])
        textAnimation(layer: weatherLabel.layer,values: [Double(percents[0]+percents[1]+percents[2]+percents[3]/2), Double(thisPercents[0]+thisPercents[1]+thisPercents[2]+thisPercents[3]/2)])
        percents = thisPercents
    }
    
    func animation(startValues: [CGFloat], layer: CAShapeLayer){
        let animation1 = CAKeyframeAnimation(keyPath: "strokeStart")
        //animation1.values = [0.0,0.0]
        animation1.values = [startValues[0], startValues[1]]
        animation1.calculationMode = .linear
        animation1.fillMode = CAMediaTimingFillMode.forwards
        animation1.isRemovedOnCompletion = false
        animation1.duration = 0.5
        animation1.repeatCount = 1
        layer.add(animation1, forKey: "yeah")
    }
    
    func textAnimation(layer: CALayer, values:[Double]){
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = [Double.pi*2*values[0], Double.pi*2*values[1]]
        animation.calculationMode = .linear
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.duration = 0.5
        animation.repeatCount = 1
        layer.add(animation, forKey: "hello")
    }
    
    func drawArch(color: UIColor, layer: CAShapeLayer){
        // progress Drawing
        r = self.frame.width/2
        let path = UIBezierPath()
        let startAngle:CGFloat = -.pi/2
        let endAngle:CGFloat = .pi*3/2
        path.addArc(withCenter:CGPoint(x:r,y:r), radius:r, startAngle:startAngle, endAngle:endAngle, clockwise:true)
        layer.path = path.cgPath
        layer.lineCap = .round
        layer.lineWidth = lineWidth
        layer.strokeColor = color.cgColor
        layer.fillColor = .none
        self.layer.addSublayer(layer)
    }
    
    
    func drawUILabel(color: UIColor, text:String, textLabel:UILabel){
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        textLabel.sizeToFit()
        textLabel.textAlignment = .center
        textLabel.layer.anchorPoint = CGPoint(x: 0.5, y: 7*UIScreen.main.bounds.width/375) //7 - 8
        textLabel.center = CGPoint(x:r,y:r)
        textLabel.textColor = color
        self.addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DataView:UIView{
    var ringView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var thumbnailButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var cancelButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    var circleView = CircularView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), width: 6, label: true)
    var fullScreenView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    //button
    
    
    
    enum State{
        case thumbnail, fullScreen
    }
    
    var state = State.thumbnail {
        didSet{
            if state == .fullScreen{
                print("fullscreen")
                
                
                UIView.animate(withDuration: 0.2,
                               animations: { [weak self] in
                                self!.cancelButtonView.alpha = 1.0
                                self!.thumbnailButtonView.alpha = 0.0
                                self!.fullScreenView.alpha = 1.0
                                buttonView.alpha = 1.0
                               })
                self.cancelButtonView.isHidden = false
                self.thumbnailButtonView.isHidden = true
                self.fullScreenView.isHidden = false
                
                
            }else{
                print("thumbnail")
                UIView.animate(withDuration: 0.2,
                               animations: { [weak self] in
                                self!.cancelButtonView.alpha = 0.0
                                self!.thumbnailButtonView.alpha = 1.0
                                self!.fullScreenView.alpha = 0.0
                                buttonView.alpha = 0.0
                               })
                self.cancelButtonView.isHidden = true
                self.thumbnailButtonView.isHidden = false
                self.fullScreenView.isHidden = true
            }
        }
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initFullScreenView()
        initRingView()
        
        cancelButtonView.alpha = 0.0
        thumbnailButtonView.alpha = 1.0
        fullScreenView.alpha = 0.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        ringView.addGestureRecognizer(tap)
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTap(){
        print("tapped")
        if state == .fullScreen {
            state = .thumbnail
            
        }else{
            state = .fullScreen 
        }
    }
    
    func initFullScreenView(){
        let r = frame.width*0.4
        circleView = CircularView.init(frame: CGRect(x: self.frame.midX-r, y: self.frame.midY-r, width: r*2, height: r*2), width: 6, label: true)
        fullScreenView.addSubview(circleView)
        self.addSubview(fullScreenView)
        fullScreenView.isHidden = true
    }
    
    func initRingView(){
        ringView.frame = CGRect(x: 0, y: self.frame.height-80, width: 80, height: 80)
        thumbnailButtonView = CircularView.init(frame: CGRect(x: 20, y: 20, width: 40, height: 40), width: 4, label: false)
        cancelButtonView.frame = CGRect(x: 20, y: 20, width: 40, height: 40)
        cancelButton()
        ringView.addSubview(thumbnailButtonView)
        ringView.addSubview(cancelButtonView)
        self.addSubview(ringView)
    }
    
    
    func cancelButton(){
        let path = UIBezierPath()
        path.move(to: CGPoint(x:10 , y:10))
        path.addLine(to: CGPoint(x: 30, y: 30))
        // Keep using the method addLine until you get to the one where about to close the path
        path.move(to: CGPoint(x:30 , y:10))
        path.addLine(to: CGPoint(x: 10, y: 30))
        path.close()
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineCap = .round
        layer.lineWidth = 2
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = .none
        cancelButtonView.layer.addSublayer(layer)
    }
}
