//
//  CameraListTableViewCell.swift
//  deKKo
//
//  Created by Arthur on 2017/4/13.
//  Copyright © 2017年 ArcCotagent. All rights reserved.
//

import UIKit
import TwilioVideo

class CameraListTableViewCell: UITableViewCell
{
    
    
    // Configure access token manually for testing, if desired! Create one manually in the console
    // at https://www.twilio.com/user/account/video/dev-tools/testing-tools
    var accessToken = "TWILIO_ACCESS_TOKEN"
    var userName = ""
    // Configure remote URL to fetch token from
    var tokenUrl = "http://dekkotest.x10host.com/?name=\(String.random())"
    
    
    
    // Video SDK components
    
    var localMedia: TVILocalMedia?
    var camera: TVICameraCapturer?
    var localVideoTrack: TVILocalVideoTrack?
    var localAudioTrack: TVILocalAudioTrack?
    var participant: TVIParticipant?
    var room: TVIRoom?
    
    
    
    
    @IBOutlet var cameraView: UIView!

    
    
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        
        
        if (accessToken == "TWILIO_ACCESS_TOKEN")
        {
            do
            {
                tokenUrl =  tokenUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                accessToken = try TokenUtils.fetchToken(url: tokenUrl)
                
                
            }
            catch
            {
                let message = "Failed to fetch access token"
                logMessage(messageText: message)
                
            }
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func logMessage(messageText:String)
    {
        print(messageText)
    }
}
