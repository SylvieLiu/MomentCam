//
//  ViewController.swift
//  Weather
//
//  Created by Sylvie on 14.09.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import CoreVideo
import AVFoundation
import MetalKit
import CoreMotion
import PhotosUI


//environment data
var amplitude: CGFloat = 0
var intensity:CGFloat = 0
var temperature: CGFloat = 0 //range 0 to +25
var clouds: CGFloat = 0 //range 0 to 100

//emotion data
var currentVal:[CGPoint] = []
var browDefault:CGFloat = 0.0
var smileRange:[CGFloat] = [0.0,0.0,0.0]
var happiness:CGFloat = 0.0
var sadness:CGFloat = 0.0
var anger:CGFloat = 0.0
var suprise:CGFloat = 0.0

//filter setting
var highlight:CGFloat = 0.0
var shadow: CGFloat = 0.0
var contrast: CGFloat = 1.0
var saturation: CGFloat = 1.0
var vib: CGFloat = 0.0
var temp: CGFloat = 0.0
var tint: CGFloat = 0.0
//distortion directions
var direction1:CIVector = CIVector(x: CGFloat.random(in: -0.4...0.4), y: CGFloat.random(in: -0.4...0.4))
var direction2:CIVector = CIVector(x: CGFloat.random(in: -0.4...0.4), y: CGFloat.random(in: -0.4...0.4))
var direction3:CIVector = CIVector(x: CGFloat.random(in: -0.4...0.4), y: CGFloat.random(in: -0.4...0.4))
var direction4:CIVector = CIVector(x: CGFloat.random(in: -0.4...0.4), y: CGFloat.random(in: -0.4...0.4))


//class
let vc = ViewController()
let faceDetection = FaceDetection()

//UI var
var weatherTrue:Bool?
var soundTrue:Bool?
var emotionTrue:Bool?
let buttonView = UIView()
let soundButton = UIButton()
let emotionButton = UIButton()
let weatherButton = UIButton()
let button =  UIButton()

//camera & uiview
var videoOutput: AVCaptureVideoDataOutput?
var startCapture = false
var multiCapture = false
var canAddFilter = false
var canDectectFace = true
let previewView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
let captureView = CaptureView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
let fadeInView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
let dataView = DataView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
let instructionView = InstructionView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
let configView = ConfigView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
let alert = UIAlertController(title: "Unsupported Device", message: "Emotion tracking is only available in front camera mode on this device.", preferredStyle: .alert)


var location:CGPoint?
var acceleration:CMAcceleration?
var lastAcceleration:CMAcceleration = CMAcceleration(x: 0, y: 0, z: 0)
var lastFrames: [CIImage] = []


//capture & live photo & asset writer
var maxFrames: Int = 40
var imageURL:URL?
var videoURL:URL?
var imageQueue:[[UIImage]] = []
var timestampQueue:[[Double]] = []
var bufferQueue:[[CVPixelBuffer]] = []
var thisResources:(pairedImage: URL, pairedVideo: URL)? = nil


//ui states
enum CaptureState {
    case idle, save, discard
}
enum UIState{
    case idle, preview, capture
}
var captureState = CaptureState.idle
var uiState = UIState.idle


class ViewController: UIViewController{
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    let motionManager = CMMotionManager()
    var rotation: CGFloat = 0.0
    let microphone = Microphone()
    
    let outputQueue = DispatchQueue(label: "outputQueue")
    let multiSession = AVCaptureMultiCamSession()
    var session = AVCaptureSession()
    let backCameraVideoDataOutput = AVCaptureVideoDataOutput()
    let frontCameraVideoDataOutput = AVCaptureVideoDataOutput()
    
    var backCamera: AVCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!
    var frontCamera: AVCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)!
    var lastZoom:CGFloat = 1.0
    var zoomLevel:CGFloat = 1.0
    
    //device orientation detection
    var orientation:CGImagePropertyOrientation = .up {
        didSet{
            print("orientation changed!", orientation)
            DispatchQueue.main.async {
                //if uiState == .capture {
                captureView.direction = self.orientation
                if (self.orientation == .up || self.orientation == .down) {
                    captureView.rotateView(self.rotation)
                }else {
                    captureView.rotateView(-self.rotation)
                }
                //}
            }
        }
    }
    
    //front & rear camera toggle
    var cameraMode:AVCaptureDevice.Position? {
        didSet{
            self.stopCaptureSession()
            self.startCaptureSession()
        }
    }
    
    var timestamps: [Double] = []
    var buffers: [CVPixelBuffer] = []
    var frames:[UIImage] = []{
        didSet {
            if (frames.count < maxFrames){
                
            } else{
                frames.remove(at:0)
                timestamps.remove(at:0)
                buffers.remove(at: 0)
            }
        }
    }
    
    let group = DispatchGroup()
    
    override func viewDidLoad() {
        if AVCaptureMultiCamSession.isMultiCamSupported{
            multiCapture = true
        }
        fadeInView.backgroundColor = .black
        
        super.viewDidLoad()
        cameraInit()
        //microphone.start()
        //initLocationManager()
        
        
        startOrientationUpdate()
        initAlertController()
        
        
        //add gesture
        initGesture()
        
        //image buffer preview
        previewView.contentMode = .scaleAspectFill
        previewView.isUserInteractionEnabled = true
        
        self.view.addSubview(captureView)
        self.view.addSubview(previewView)
        
        /*
         if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
         self.view.addSubview(instructionView)
         }*/
        
        self.view.addSubview(fadeInView)
        previewView.addSubview(dataView)
        previewView.addSubview(buttonView)
        buttonView.alpha = 0.0
        buttonSetup()
        
        //check app enter background
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        //check if the user has face data saved
        if UserDefaults.standard.float(forKey: "browDefault") != 0.0{
            browDefault = CGFloat(UserDefaults.standard.float(forKey: "browDefault"))
            let sadDefault  = CGFloat(UserDefaults.standard.float(forKey: "sadDefault"))
            let normalDefault  = CGFloat(UserDefaults.standard.float(forKey: "normalDefault"))
            let smileDefault  = CGFloat(UserDefaults.standard.float(forKey: "smileDefault"))
            smileRange = [sadDefault,normalDefault,smileDefault]
            canAddFilter = true
            cameraMode = .back
        }else{
            self.view.addSubview(configView)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            cameraMode = .front
            dataView.isHidden = true
        }
    }
    
    
    //unsupported device alert
    func initAlertController(){
        let okButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okButton)
    }
    
    //save face data on first launch
    @objc func appMovedToBackground() {
        print("App moved to background!")
        setUserDefault()
    }
    
    func setUserDefault(){
        UserDefaults.standard.set(browDefault, forKey: "browDefault")
        UserDefaults.standard.set(smileRange[0], forKey: "sadDefault")
        UserDefaults.standard.set(smileRange[1], forKey: "normalDefault")
        UserDefaults.standard.set(smileRange[2], forKey: "smileDefault")
    }
    
}



