//
//  CameraViewController.swift
//  deKKo
//
//  Created by YangSzu Kai on 2017/3/23.
//  Copyright © 2017年 ArcCotagent. All rights reserved.
//

import UIKit
import AVFoundation
import LFLiveKit

class CameraViewController: UIViewController,LFLiveSessionDelegate {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var stateL: UILabel!
   
    //Initalize basic camera and audio configuration
    lazy var session: LFLiveSession = {
        
        let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration(for: LFLiveAudioQuality.high)
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.high2)
        
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        session?.delegate = self
        session?.captureDevicePosition = .back
        session?.preView = self.view
        
        
        return session!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
        session.preView = self.view
        
        self.requestAccessForVideo()
        self.requestAccessForAudio()
        self.view.backgroundColor = UIColor.clear
        cameraView.backgroundColor = UIColor.clear
        cameraView.autoresizingMask = [UIViewAutoresizing.flexibleHeight,UIViewAutoresizing.flexibleHeight]
 
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.running = true
        
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.running = false
        
    }
    
    //Check for authentication and ask for authentication
    func requestAccessForVideo() -> Void {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch status  {
                //Ask for permission if not authorized
                case AVAuthorizationStatus.notDetermined:
                        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                            if(granted){
                                    DispatchQueue.main.async {
                                    self.session.running = true
                                }
                            }
                        })
            break
            
                //Authorized start the session
                case AVAuthorizationStatus.authorized:
                        session.running = true
                        break
            
                //When its being denied
                case AVAuthorizationStatus.denied:
                    break
            
                //When its being restricted
                case AVAuthorizationStatus.restricted:
                    break
            
                default:
                    break
        }
    }

     func requestAccessForAudio() -> Void {
        
            let status = AVCaptureDevice.authorizationStatus(forMediaType:AVMediaTypeAudio)
        
            switch status  {
                
                    case AVAuthorizationStatus.notDetermined:
                        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (granted) in
                
                        })
            
                    case AVAuthorizationStatus.authorized:
                        break
       
                    case AVAuthorizationStatus.denied:
                        break
                    case AVAuthorizationStatus.restricted:
                        break
        default:
            break
        }
    }
    
    //Change the position of camera
    @IBAction func switchCameraPosition(_ sender: Any) {
        
        //The current position of the camera
        let devicePosition = session.captureDevicePosition
        
        if devicePosition == AVCaptureDevicePosition.back {
            //Change to the front
            session.captureDevicePosition = .front
            
        }else{
            //Change to back
            session.captureDevicePosition = .back
            
        }
    }
    
   }

