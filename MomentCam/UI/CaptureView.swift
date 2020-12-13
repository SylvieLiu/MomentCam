//
//  OutputView.swift
//
//
//  Created by Sylvie on 26.10.20.
//

import Foundation
import UIKit

class CaptureView: UIView {
    var imageView:UIImageView?
    var overlayView:UIView?
    var contentView:UIView?
    var textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var discardButton = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var saveButton = UIView (frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    
    let grey = UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0)
    let purple = UIColor(red: 96/255, green: 87/255, blue: 198/255, alpha: 1.0)
    let bgColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    var buttonSize:CGFloat = 48
    
    var direction:CGImagePropertyOrientation = .up

    
    var image:UIImage? {
        didSet{
            imageView?.image = image
        }
    }
    
    enum State {
        case idle, overlay, save, discard, saved, discarded
    }
    
    var state = State.idle {
        didSet{
            if state == .overlay{
                //rotateView()
                stateOverlay()
            }else if state == .save{
                stateSave()
            }else if state == .saved{
                stateSaved()

            }else if state == .discard{
                stateDiscard()
            }else if state == .discarded{
                stateDiscarded()
            }
            
            else if state == .idle{
                stateDefault()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: self.frame)
        imageView!.contentMode = .scaleAspectFill
        
        self.addSubview(imageView!)
        initOverlayView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initOverlayView(){
        overlayView = UIView(frame: self.frame)
        contentView = UIView(frame: CGRect(x: 0, y: self.frame.midY-self.frame.width/2, width: self.frame.width, height: self.frame.width))
        self.addSubview(overlayView!)
        overlayView?.backgroundColor = bgColor
        overlayView?.alpha = 0
        textLabel.text="Drag up to discard \nDrag down to save"
        textLabel.numberOfLines = 2
        textLabel.font = .systemFont(ofSize: 20, weight: .medium)
        textLabel.sizeToFit()
        textLabel.center = CGPoint(x: contentView!.frame.width/2, y: contentView!.frame.height/2)
        textLabel.textAlignment = .center
        textLabel.textColor = .white
        overlayView?.addSubview(contentView!)
        contentView!.addSubview(textLabel)
        drawDiscardButton()
        drawSaveButton()
    }
    
    func stateOverlay(){
        overlayView?.transform = CGAffineTransform(translationX: 0, y: 0)
        overlayView?.fadeIn(duration: 0.15)
    }
    
    func stateSave(){
        UIView.animate(withDuration: 0.2,
                               animations: { [self] in
                                saveButton.alpha = 1.0
                               saveButton.frame = CGRect(x: contentView!.frame.width/2-buttonSize/2, y: contentView!.frame.height/2-buttonSize/2, width: buttonSize, height: buttonSize)
                                discardButton.frame = CGRect(x: contentView!.frame.width/2-buttonSize/2, y: contentView!.frame.height/2-buttonSize/2, width: buttonSize, height: buttonSize)
                                discardButton.alpha = 0.0
                                textLabel.alpha = 0.0
                })
    }
    
    func stateDiscard(){
        UIView.animate(withDuration: 0.2,
                               animations: { [self] in
                                discardButton.alpha = 1.0
                                discardButton.frame = CGRect(x: contentView!.frame.width/2-buttonSize/2, y: contentView!.frame.height/2-buttonSize/2, width: buttonSize, height: buttonSize)
                                saveButton.frame = CGRect(x: contentView!.frame.width/2-buttonSize/2, y: contentView!.frame.height/2-buttonSize/2, width: buttonSize, height: buttonSize)
                                saveButton.alpha = 0.0
                                textLabel.alpha = 0.0
                })
    }
    
    func stateSaved(){
        saveButton.alpha = 0.0
        textLabel.text = "saved"
        textLabel.alpha = 1.0
        UIView.animate(withDuration: 0.5,animations: { [self] in
            //saveButton.alpha = 0.0
            overlayView?.backgroundColor = purple
            
            }, completion: {_ in
            
                self.transitionSave()
        })
    }
    
    
    
    func stateDiscarded(){
        discardButton.alpha = 0.0
        textLabel.text = "discarded"
        textLabel.alpha = 1.0
        UIView.animate(withDuration: 0.5,
                               animations: { [self] in
                                //discardButton.alpha = 0.0
                                overlayView?.backgroundColor = grey
                                
                                
                               }, completion: {_ in
                                self.transitionDiscard()
                               })
    }
    
    func stateDefault(){
        overlayView?.fadeOut(duration: 0.15)
        overlayView?.backgroundColor = bgColor
        saveButton.alpha = 1.0
        discardButton.alpha = 1.0
        textLabel.text="Drag up to discard \nDrag down to save"
        discardButton.frame = CGRect(x: contentView!.frame.width/2-buttonSize/2, y: contentView!.frame.height/2-50-buttonSize, width: buttonSize, height: buttonSize)
        saveButton.frame = CGRect(x: contentView!.frame.width/2-22, y: contentView!.frame.height/2+50, width: buttonSize, height: buttonSize)
    }
    
    func drawDiscardButton(){
        discardButton.frame = CGRect(x: contentView!.frame.width/2-buttonSize/2, y: contentView!.frame.height/2-50-buttonSize, width: buttonSize, height: buttonSize)
        let r = buttonSize*0.18
        let path = UIBezierPath()
        path.move(to: CGPoint(x:buttonSize/2-r , y:buttonSize/2-r))
        path.addLine(to: CGPoint(x:buttonSize/2+r, y: buttonSize/2+r))
        path.move(to: CGPoint(x:buttonSize/2+r , y:buttonSize/2-r))
        path.addLine(to: CGPoint(x:buttonSize/2-r, y:buttonSize/2+r))
        path.close()
        
        let circle = UIBezierPath()
        circle.addArc(withCenter:CGPoint(x:discardButton.frame.width/2,y:discardButton.frame.width/2), radius:discardButton.frame.width/2, startAngle:0, endAngle:.pi*2, clockwise:true)
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = circle.cgPath
        circleLayer.fillColor = grey.cgColor
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineCap = .round
        layer.lineWidth = 2
        layer.strokeColor = UIColor.white.cgColor
        
        discardButton.layer.addSublayer(circleLayer)
        discardButton.layer.addSublayer(layer)
        contentView?.addSubview(discardButton)
    }
    
    func drawSaveButton(){
        saveButton.frame = CGRect(x: contentView!.frame.width/2-buttonSize/2, y: contentView!.frame.height/2+50, width: buttonSize, height: buttonSize)
        let r = buttonSize*0.2
        let path = UIBezierPath()
        path.move(to: CGPoint(x:buttonSize/2-r , y:buttonSize/2))
        path.addLine(to: CGPoint(x: buttonSize/2, y: buttonSize/2+r))
        path.move(to: CGPoint(x: buttonSize/2, y: buttonSize/2+r))
        path.addLine(to: CGPoint(x: buttonSize/2+r, y: buttonSize/2))
        path.move(to: CGPoint(x: buttonSize/2, y: buttonSize/2+r))
        path.addLine(to: CGPoint(x: buttonSize/2, y: buttonSize/2-r))
        path.close()
        
        let circle = UIBezierPath()
        circle.addArc(withCenter:CGPoint(x:saveButton.frame.width/2,y:saveButton.frame.width/2), radius:saveButton.frame.width/2, startAngle:0, endAngle:.pi*2, clockwise:true)
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = circle.cgPath
        circleLayer.fillColor = purple.cgColor
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineCap = .round
        layer.lineWidth = 2
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = purple.cgColor
    
        saveButton.layer.addSublayer(circleLayer)
        saveButton.layer.addSublayer(layer)
        contentView?.addSubview(saveButton)
    }

    
    func slidePush(finished: () -> Void) {
        // Create a CATransition
        let transition = CATransition()

        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.linear)
        overlayView!.layer.add(transition, forKey: kCATransition)
        finished()
    }
    
    func rotateView(_ angle:CGFloat){
        contentView!.transform = CGAffineTransform(rotationAngle: angle);
        /*UIView.animate(withDuration: 0.2,
                               animations: { [self] in
                                contentView!.transform = CGAffineTransform(rotationAngle: angle);
                               }, completion: {_ in
                  
                               })*/
    }

    func transitionSave(){
        UIView.animate(withDuration: 0.2,
                               animations: { [self] in
                                switch direction{
                                case .up:
                                    overlayView!.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
                                    break
                                case .down:
                                    overlayView!.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
                                    break
                                    
                                case .left:
                                    overlayView!.transform = CGAffineTransform(translationX: -self.frame.width, y: 0)
                                    break
                                    
                                case .right:
                                    overlayView!.transform = CGAffineTransform(translationX: self.frame.width, y: 0)
                                    break
                                default:
                                    return
                                }
                                
                               }, completion: {_ in
                                uiState = .preview
                                self.state = .idle
                               })
    }

    
    func transitionDiscard(){
        UIView.animate(withDuration: 0.2,
                               animations: { [self] in
                                
                                switch direction{
                                case .up:
                                    overlayView!.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
                                    break
                                case .down:
                                    overlayView!.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
                                    break
                                    
                                case .left:
                                    overlayView!.transform = CGAffineTransform(translationX: self.frame.width, y: 0)
                                    break
                                    
                                case .right:
                                    overlayView!.transform = CGAffineTransform(translationX: -self.frame.width, y: 0)
                                    break
                                default:
                                    return
                                }
                                
                               }, completion: {_ in
                                uiState = .preview
                                self.state = .idle
                               })
    }
    
}


