//
//  InstructionView.swift
//  MomentCam
//
//  Created by Sylvie on 12.12.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//

import Foundation
import UIKit

//face detection data on first launch
class ConfigView: UIView {
    let label = UILabel()
    let subview = UIView()
    let subviewButton =  UIButton()
    let subviewLabel = UILabel()
    let subviewLabel2 = UILabel()
    
    enum State {
        case idle, normal, smile, sad, done
    }
    
    var state = State.idle {
        didSet{
            if state == .idle {
                
            }
            else if state == .normal{
                label.text = "look into the camera"
                button.setTitle("I'm looking", for: .normal)
            }else if state == .smile{
                label.text = "now smile😀"
                button.setTitle("I'm smiling", for: .normal)
            } else if state == .sad{
                label.text = "make a sad face🙁"
                button.setTitle("I'm sad", for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subview.frame = frame
        state = .normal
        initView()
        initSubview()
        self.addSubview(subview)
        getRandomColor()
    }
    
    func getRandomColor() {
        let blue:UIColor = UIColor(red: 50/255, green: 178/255, blue: 214/255, alpha: 1.0)
        let pink:UIColor = UIColor(red: 229/255, green: 31/255, blue: 111/255, alpha: 1.0)
        let purple:UIColor = UIColor(red: 112/255, green: 61/255, blue: 163/255, alpha: 1.0)
        var currentColor = purple
        
        if currentColor == pink {
            currentColor = purple
        }  else if currentColor == purple {
            currentColor = blue
        } else if currentColor == blue {
            currentColor = pink
        }
        
        
        UIView.animate(withDuration: 2.0, delay: 0.0, options:[.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.subview.backgroundColor = currentColor
        }, completion:nil)
    }
    
    func initSubview(){
        label.isHidden = true
        button.isHidden = true
        subview.backgroundColor = .init(red: 120/255, green: 69/255, blue: 203/255, alpha: 1.0)
        
        subviewButton.frame = CGRect(x: self.frame.midX-self.frame.width*0.25, y: self.frame.midY+self.frame.height*0.17, width: self.frame.width*0.5, height: self.frame.width*0.14)
        subviewButton.backgroundColor = .clear
        subviewButton.layer.cornerRadius = 7
        subviewButton.layer.borderWidth = 2
        subviewButton.setTitle("Let's go!", for: .normal)
        subviewButton.layer.borderColor = .init(red: 1, green: 1, blue: 1, alpha: 0.7)
        subviewButton.addTarget(self, action: #selector(subviewButtonTapped(_:)), for: .touchUpInside)
        subview.addSubview(subviewButton)
        subview.addSubview(subviewLabel)
        subview.addSubview(subviewLabel2)
        
        subviewLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        subviewLabel.text = "Just one step away!"
        subviewLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        subviewLabel.textColor = .white
        subviewLabel.numberOfLines = 1
        subviewLabel.sizeToFit()
        subviewLabel.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2-self.frame.height*0.2)
        subviewLabel.textAlignment = .center
        
        
        subviewLabel2.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        subviewLabel2.text = "We still need to calibrate \nyour face data"
        subviewLabel2.font = .systemFont(ofSize: 18, weight: .medium)
        subviewLabel2.textColor = .white
        subviewLabel2.numberOfLines = 5
        subviewLabel2.sizeToFit()
        subviewLabel2.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2-self.frame.height*0.1)
        subviewLabel2.textAlignment = .center
    }
    
    
    func initView(){
        self.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.5)
        button.frame = CGRect(x: self.frame.midX-self.frame.width*0.25, y: self.frame.midY+self.frame.height*0.28, width: self.frame.width*0.5, height: self.frame.width*0.14)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 2
        button.setTitle("I'm looking!", for: .normal)
        button.layer.borderColor = .init(red: 1, green: 1, blue: 1, alpha: 0.7)
        self.addSubview(button)
        
        self.addSubview(label)
        
        label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        //label.frame = CGRect(x: self.frame.midX-self.frame.width*0.5/2, y: self.frame.midY-self.frame.height*0.4, width: self.frame.width*0.5, height: self.frame.width*0.15)
        label.text = "look into the camera"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.sizeToFit()
        label.center = CGPoint(x: self.frame.width/2, y: self.frame.midY-self.frame.height*0.35)
        label.textAlignment = .center
    }
    
    @objc func subviewButtonTapped(_ sender: UIButton){
        print("button tapped")
        state = .normal
        
        subview.fadeOut(duration: 0.15, completion: {_ in
            self.subview.removeFromSuperview()
            self.label.isHidden = false
            button.isHidden = false
            //enable filters
            // switch to back camera view
        })
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ViewController{
    @objc func buttonTapped(_ sender: UIButton){
        print("tapped")
        if configView.state == .normal {
            configView.state = .smile
            if currentVal != [] {
                let middlePoint = CGPoint(x: (currentVal[27].x+currentVal[34].x)/2, y: (currentVal[27].y+currentVal[34].y)/2)
                let distance = CGPointDistance(from: middlePoint, to: currentVal[30])/CGPointDistance(from: middlePoint, to: currentVal[37])
                smileRange[1] = distance
                
                
                let distanceLeft = CGPointDistance(from: currentVal[1], to: currentVal[16])
                let distanceRight = CGPointDistance(from: currentVal[8], to: currentVal[22])
                browDefault = (distanceLeft+distanceRight)/2
            } else{
                return
            }
        }
        
        else if configView.state == .smile {
            configView.state = .sad
            if currentVal != [] {
                let middlePoint = CGPoint(x: (currentVal[27].x+currentVal[34].x)/2, y: (currentVal[27].y+currentVal[34].y)/2)
                let distance = CGPointDistance(from: middlePoint, to: currentVal[30])/CGPointDistance(from: middlePoint, to: currentVal[37])
                smileRange[2] = distance
            } else{
                return
            }
            
        } else if configView.state == .sad {
            configView.state = .done
            if currentVal != [] {
                let middlePoint = CGPoint(x: (currentVal[27].x+currentVal[34].x)/2, y: (currentVal[27].y+currentVal[34].y)/2)
                let distance = CGPointDistance(from: middlePoint, to: currentVal[30])/CGPointDistance(from: middlePoint, to: currentVal[37])
                smileRange[0] = distance
            } else{
                return
            }
            
            configView.fadeOut(duration: 0.15, completion: {_ in
                //enable filters
                // switch to back camera view
                canAddFilter = true
                
                self.cameraMode = .back
                configView.removeFromSuperview()
                
                
                instructionView.alpha = 0.0
                self.view.addSubview(instructionView)
                instructionView.fadeIn(duration: 0.2)
                dataView.isHidden = false
            })
        }
    }
}


