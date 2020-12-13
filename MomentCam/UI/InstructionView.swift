//
//  InstructionView.swift
//  MomentCam
//
//  Created by Sylvie on 12.12.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//

import Foundation
import UIKit


class InstructionView: UIView {
    let button =  UIButton()
    let swipeIcon = UIImageView()
    let tapIcon = UIImageView()
    let swipeLabel = UILabel()
    let tapLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.7)
        button.frame = CGRect(x: self.frame.midX-self.frame.width*0.27, y: self.frame.midY+self.frame.width*0.3, width: self.frame.width*0.54, height: self.frame.width*0.14)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 2
        button.setTitle("Got it!", for: .normal)
        button.layer.borderColor = .init(red: 1, green: 1, blue: 1, alpha: 0.7)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        self.addSubview(button)
        self.addSubview(swipeIcon)
        self.addSubview(swipeLabel)
        self.addSubview(tapIcon)
        self.addSubview(tapLabel)
        
        tapLabel.frame = CGRect(x: self.frame.midX-self.frame.width*0.05, y: self.frame.midY-self.frame.width*0.4, width: self.frame.width*0.5, height: self.frame.width*0.15)
        tapLabel.text = "Tap anywhere \nto take photo"
        tapLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        tapLabel.textColor = .white
        tapLabel.numberOfLines = 2
        
        
        
        swipeLabel.frame = CGRect(x: self.frame.midX-self.frame.width*0.05, y: self.frame.midY-self.frame.width*0.1, width: self.frame.width*0.5, height: self.frame.width*0.15)
        swipeLabel.text = "Swipe to \ntoggle camera"
        swipeLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        swipeLabel.textColor = .white
        swipeLabel.numberOfLines = 2
        
        tapIcon.frame = CGRect(x: self.frame.midX-self.frame.width*0.3, y: self.frame.midY-self.frame.width*0.4, width: self.frame.width*0.15, height: self.frame.width*0.15)
        tapIcon.contentMode = .scaleAspectFit
        tapIcon.image = UIImage(named: "tap")
        
        swipeIcon.frame = CGRect(x: self.frame.midX-self.frame.width*0.3, y: self.frame.midY-self.frame.width*0.1, width: self.frame.width*0.15, height: self.frame.width*0.15)
        swipeIcon.contentMode = .scaleAspectFit
        swipeIcon.image = UIImage(named: "swipe")
    }
    
    @objc func buttonTapped(_ sender: UIButton){
        print("button pressed")
        self.fadeOut(duration: 0.15, completion: {_ in
            self.removeFromSuperview()
        })
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
