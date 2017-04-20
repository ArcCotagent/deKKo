//
//  CameraViewController.swift
//  deKKo
//
//  Created by YangSzu Kai on 2017/3/23.
//  Copyright © 2017年 ArcCotagent. All rights reserved.
//

import UIKit
import TwilioVideo
import Parse

class CameraViewController: UIViewController
{


    // Configure access token manually for testing, if desired! Create one manually in the console
    // at https://www.twilio.com/user/account/video/dev-tools/testing-tools
    var accessToken = "TWILIO_ACCESS_TOKEN"
    var userName = ""
    // Configure remote URL to fetch token from
    var tokenUrl = "http://dekkotest.x10host.com/?name="
    
    
    // Video SDK components
    
    var localMedia: TVILocalMedia?
    var camera: TVICameraCapturer?
    var localVideoTrack: TVILocalVideoTrack?
    var localAudioTrack: TVILocalAudioTrack?
    var participant: TVIParticipant?
    var room: TVIRoom?
    var type: TVIVideoCaptureSource!
    var flag = 0
    

    
    var roomInfos: [PFObject] = []


    let defaults = UserDefaults.standard
    
    
    @IBOutlet var localCameraView: UIView!

    @IBOutlet weak var stateL: UILabel!

    @IBOutlet weak var buttonRecord: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // LocalMedia represents the collection of tracks that we are sending to other Participants from our VideoClient.
        if !PlatformUtils.isSimulator
        {
            localMedia = TVILocalMedia()

            //Making it to full screen
            let renderer = TVIVideoViewRenderer.init()
            localVideoTrack?.addRenderer(renderer)
            renderer.view.frame = localCameraView.bounds
            renderer.view.contentMode = .scaleAspectFill
            localCameraView.addSubview(renderer.view)
            
            //With one tap change camera view
            let tapToSwitch = UITapGestureRecognizer(target: self, action: #selector(self.flipCamera(_:)))
            self.localCameraView.addGestureRecognizer(tapToSwitch)

        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        camera = TVICameraCapturer()
        localVideoTrack = localMedia?.addVideoTrack(true, capturer: camera!)
        localVideoTrack?.attach(self.localCameraView)
        
        //Making it to full screen
        let renderer = TVIVideoViewRenderer.init()
        localVideoTrack?.addRenderer(renderer)
        renderer.view.frame = localCameraView.bounds
        renderer.view.contentMode = .scaleAspectFill
        localCameraView.addSubview(renderer.view)

        
    }
   
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let localVideoTrack = localVideoTrack
        {
            self.localMedia?.removeVideoTrack(localVideoTrack)
            self.room?.disconnect()
        }
        
    }
    
    @IBAction func flipCamera(_ sender: Any)
    {
        if (self.camera?.source == .frontCamera) {
            self.camera?.selectSource(.backCameraWide)
        } else {
            self.camera?.selectSource(.frontCamera)
        }

    }
    
    @IBAction func StartLive(_ sender: Any)
    {
        
        if (flag == 0 ){
           type  = (self.camera?.source)!
            
            
            connect()
            
            if(type == .backCameraWide)
            {
                self.camera?.selectSource(.backCameraWide)
            }
            
            let onR = UIImage(named: "onRecord")
            self.buttonRecord.setImage(onR , for: .normal)
            flag = 1
        }
        else if (flag == 1 )
        {
            clearRoomNameInTheServer()
            if let localVideoTrack = localVideoTrack
            {
                self.localMedia?.removeVideoTrack(localVideoTrack)
                self.room?.disconnect()
            }
            
            let offR = UIImage(named: "110911-200")
            self.buttonRecord.setImage(offR , for: .normal)
            flag = 0;
            
            
            
            
            camera = TVICameraCapturer()
            localVideoTrack = localMedia?.addVideoTrack(true, capturer: camera!)
            localVideoTrack?.attach(self.localCameraView)
            
            //Making it to full screen
            let renderer = TVIVideoViewRenderer.init()
            localVideoTrack?.addRenderer(renderer)
            renderer.view.frame = localCameraView.bounds
            renderer.view.contentMode = .scaleAspectFill
            localCameraView.addSubview(renderer.view)
            self.camera?.selectSource(type)
        }
        
    }
    
    func connect()
    {
        if (accessToken == "TWILIO_ACCESS_TOKEN") {
            do {
                
                let userInfo = defaults.object(forKey: "userInfo") as? Dictionary<String, Any>
                
                if let userInfo = userInfo
                {
                    userName = userInfo["userName"] as! String
                    
                    tokenUrl+=userName
                    tokenUrl =  tokenUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                    accessToken = try TokenUtils.fetchToken(url: tokenUrl)
                }
                else
                {
                    print("Failed to retrive userInfo")
                }
                
            } catch {
                let message = "Failed to fetch access token"
                logMessage(messageText: message)
                return
            }
        }

        
        self.prepareLocalMedia()
        let connectOptions = TVIConnectOptions.init(token: accessToken) { (builder) in
            builder.roomName = String.random()
            builder.localMedia = self.localMedia
        }
        
        room = TVIVideoClient.connect(with: connectOptions, delegate: self)
    }
    func logMessage(messageText:String)
    {
        print(messageText)
    }
    
    func prepareLocalMedia()
    {
        
        if(PlatformUtils.isSimulator)
        {
            return
        }
        camera = TVICameraCapturer()
        self.localVideoTrack = self.localMedia?.addVideoTrack(true, capturer: camera!)
        // We will offer local audio and video when we connect to room.
        
        // Adding local audio track to localMedia
        if (localAudioTrack == nil) {
            localAudioTrack = localMedia?.addAudioTrack(true)
        }
       
        let renderer = TVIVideoViewRenderer.init()
        localVideoTrack?.addRenderer(renderer)
        renderer.view.frame = localCameraView.bounds
        renderer.view.contentMode = .scaleAspectFill
        localCameraView.addSubview(renderer.view)

        
        
        //localVideoTrack?.attach(self.localCameraView)
        
        
        
        if (localVideoTrack == nil)
        {
            print( "Failed to add video track")
        }
        // Adding local video track to localMedia and starting local preview if it is not already started.
        
    }
    
    @IBAction func logout(_ sender: Any)
    {
         clearRoomNameInTheServer()
        
        if(PFUser.current() != nil)
        {
            PFUser.logOut()
        }
        defaults.set(nil, forKey: "userInfo")
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let vc = main.instantiateViewController(withIdentifier: "loginVIew")
        present(vc, animated: true, completion: {})

    }
    func clearRoomNameInTheServer()
    {
        let query = PFQuery(className: "ROOMINFO")
        query.order(byDescending: "roomName")
        query.includeKey("roomName")
        //query.whereKey("roomName", equalTo: room?.name as! String)
        
        query.limit = 20
        
        
        query.findObjectsInBackground { (roomInfos: [PFObject]?, error: Error?) -> Void in
            
            print(roomInfos)
            
            if let roomInfos = roomInfos
            {
                for index  in 0 ..< roomInfos.count
                {
                    if let roomName = roomInfos[index]["roomName"] as? String
                    {
                        if(roomName == self.room!.name)
                        {
                            
                            if let participants = roomInfos[0]["participants"] as? Int
                            {
                                if participants == 0
                                {
                                    roomInfos[0].deleteInBackground()
                                }
                                
                            }
                            
                        }
                    }
                    
                }
                
                
                
                //self.roomInfos = roomInfos
                
            }
            else
            {
                print(error?.localizedDescription)
                // handle error
            }
        }
        
    }
    
    
    
}
extension String {
    
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}


extension CameraViewController : TVIRoomDelegate {
    func didConnect(to room: TVIRoom) {
        // The Local Participant
        let localParticipant = room.localParticipant;
        print("Local identity \(localParticipant!.identity)")
        
        var roomInfo = PFObject(className: "ROOMINFO")
        
    
        roomInfo["roomName"] = room.name
        roomInfo["participants"] = room.participants.count;
        roomInfo.saveInBackground()
        
        
        // Connected participants
        let participants = room.participants;
        print("Number of connected participants \(participants.count)")
        if (room.participants.count > 0) {
            self.participant = room.participants[0]
            self.participant?.delegate = self
        }
        
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIParticipant) {
        print ("Participant \(participant.identity) has joined Room \(room.name)")
        if (self.participant == nil) {
            self.participant = participant
            self.participant?.delegate = self
        }
        
    }
    
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIParticipant) {
        print ("Participant \(participant.identity) has left Room \(room.name)")
    }
    
}

// MARK: TVIParticipantDelegate

extension CameraViewController : TVIParticipantDelegate {
    func participant(_ participant: TVIParticipant, addedVideoTrack videoTrack: TVIVideoTrack) {
        //logMessage(messageText: "Participant \(participant.identity) added video track")
        
        if (self.participant == participant) {
            //videoTrack.attach(self.remoteView)
        }
    }
    
    func participant(_ participant: TVIParticipant, removedVideoTrack videoTrack: TVIVideoTrack) {
        // logMessage(messageText: "Participant \(participant.identity) removed video track")
        
        if (self.participant == participant) {
      //      videoTrack.detach(self.remoteView)
        }
    }
    
    func participant(_ participant: TVIParticipant, addedAudioTrack audioTrack: TVIAudioTrack) {
        //  logMessage(messageText: "Participant \(participant.identity) added audio track")
        
    }
    
    func participant(_ participant: TVIParticipant, removedAudioTrack audioTrack: TVIAudioTrack) {
        // logMessage(messageText: "Participant \(participant.identity) removed audio track")
    }
    
    func participant(_ participant: TVIParticipant, enabledTrack track: TVITrack) {
        var type = ""
        if (track is TVIVideoTrack) {
            type = "video"
        } else {
            type = "audio"
        }
        // logMessage(messageText: "Participant \(participant.identity) enabled \(type) track")
    }
    
    func participant(_ participant: TVIParticipant, disabledTrack track: TVITrack) {
        var type = ""
        if (track is TVIVideoTrack) {
            type = "video"
        } else {
            type = "audio"
        }
        //  logMessage(messageText: "Participant \(participant.identity) disabled \(type) track")
    }
}

