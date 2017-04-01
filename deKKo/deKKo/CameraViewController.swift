//
//  CameraViewController.swift
//  deKKo
//
//  Created by YangSzu Kai on 2017/3/23.
//  Copyright © 2017年 ArcCotagent. All rights reserved.
//

import UIKit
import TwilioVideo

class CameraViewController: UIViewController
{


    // Configure access token manually for testing, if desired! Create one manually in the console
    // at https://www.twilio.com/user/account/video/dev-tools/testing-tools
    var accessToken = "TWILIO_ACCESS_TOKEN"
    var userName = ""
    // Configure remote URL to fetch token from
    var tokenUrl = "http://dekkotest.000webhostapp.com/?name="
    
    
    // Video SDK components
    
    var localMedia: TVILocalMedia?
    var camera: TVICameraCapturer?
    var localVideoTrack: TVILocalVideoTrack?
    var localAudioTrack: TVILocalAudioTrack?
    var participant: TVIParticipant?
    var room: TVIRoom?
    
    
    let defaults = UserDefaults.standard
    
    
    @IBOutlet var localCameraView: UIView!

    @IBOutlet weak var stateL: UILabel!

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        localMedia = TVILocalMedia()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      
        
    }
    
    @IBAction func StartLive(_ sender: Any)
    {
        connect()
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
            builder.roomName = "room123"
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
       
        localVideoTrack?.attach(self.localCameraView)
        
        
        
        if (localVideoTrack == nil)
        {
            print( "Failed to add video track")
        }
        // Adding local video track to localMedia and starting local preview if it is not already started.
        
    }

    
}
extension CameraViewController : TVIRoomDelegate {
    func didConnect(to room: TVIRoom) {
        // The Local Participant
        let localParticipant = room.localParticipant;
        print("Local identity \(localParticipant!.identity)")
        
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

