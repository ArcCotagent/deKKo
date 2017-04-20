//
//  CameraListViewController.swift
//  deKKo
//
//  Created by Arthur on 2017/4/4.
//  Copyright © 2017年 ArcCotagent. All rights reserved.
//

import UIKit
import TwilioVideo
import Parse

class CameraListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    var roomNameNum:Int = 0;
    var roomNum = 0;
    var roomNameArray:[String] = []
    //var cellArray:[CameraListTableViewCell] = []
    var roomInfos: [PFObject] = []
    //var tableIndex = 0;
    //var cell:CameraListTableViewCell?
    var refreshControl: UIRefreshControl!
    
    
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        getRoomInfos()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reload(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Get the RoomInfo from Parse
    func getRoomInfos()
    {
        //Query the table ROOMINFO
        let query = PFQuery(className: "ROOMINFO")
        //Sort the table by roomName
        query.order(byDescending: "roomName")
        
        //Grab only 20 Orders
        query.limit = 20
        
        //Start Grabing
        query.findObjectsInBackground { (roomInfos: [PFObject]?, error: Error?) -> Void in
            if let roomInfos = roomInfos
            {
                //Save it to roomInfos[]
                self.roomInfos = roomInfos
                
                print(roomInfos)
                
                
                self.roomNameArray = []
                
                for index in 0 ..< roomInfos.count
                {
                    //Get only roomName
                    if let roomName = roomInfos[index]["roomName"] as? String
                    {
                        self.roomNameArray.append(roomName)
                    }
                    
                }
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                print("Available rooms:\n \(self.roomNameArray)")
                //let post = self.posts[indexPath.row]
                // self.tableView.reloadData()
                
                // do something with the data fetched
            }
            else
            {
                // handle error
            }
        }
        
    }
    

    func reload(_ sender: Any)
    {
        //cellArray = []
        //tableIndex = 0;
        getRoomInfos()
        tableView.reloadData()

    }
  
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        return roomNameArray.count
        
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CameraListCell", for: indexPath) as! CameraListTableViewCell
        
        
        
        let connectOptions = TVIConnectOptions.init(token: cell.accessToken) { (builder) in
            builder.roomName = self.roomNameArray[indexPath.row]
        }
        //Start connection
        cell.connectOptions = connectOptions
        
        cell.connect()
        
        //cellArray.append(cell)
        
        
        
        
        return cell
    }
    
    func logMessage(messageText:String)
    {
        print(messageText)
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
// MARK: TVIRoomDelegate

/*
extension CameraListViewController : TVIRoomDelegate {
    func didConnect(to room: TVIRoom) {
        
        // At the moment, this example only supports rendering one Participant at a time.
        
        logMessage(messageText: "Connected to room \(room.name) as \(room.localParticipant?.identity)")
        
        if (room.participants.count > 0)
        {
            print(tableIndex)
            cellArray[tableIndex].participant = room.participants[0]
            cellArray[tableIndex].participant?.delegate = self
        }
    }
    
    func room(_ room: TVIRoom, didDisconnectWithError error: Error?) {
        logMessage(messageText: "Disconncted from room \(room.name), error = \(error)")
        
        // self.cleanupRemoteParticipant()
        //self.room = nil
        
        // self.showRoomUI(inRoom: false)
    }
    
    func room(_ room: TVIRoom, didFailToConnectWithError error: Error) {
        logMessage(messageText: "Failed to connect to room with error")
        
        print(error.localizedDescription)
        //self.room = nil
        
        //self.showRoomUI(inRoom: false)
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIParticipant) {
        
        /*
         if (cell?.participant == nil) {
         cell?.participant = participant
         cell?.participant?.delegate = self
         }
         logMessage(messageText: "Room \(room.name), Participant \(participant.identity) connected")
         */
    }
    
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIParticipant) {
//        if (cell?.participant == participant) {
//            //cleanupRemoteParticipant()
//        }
        logMessage(messageText: "Room \(room.name), Participant \(participant.identity) disconnected")
    }
}

// MARK: TVIParticipantDelegate
extension CameraListViewController : TVIParticipantDelegate {
    func participant(_ participant: TVIParticipant, addedVideoTrack videoTrack: TVIVideoTrack) {
        logMessage(messageText: "Participant \(participant.identity) added video track")
        
//        if let cell = self.cell
//        {
//        let indexpath = IndexPath(row: tableIndexPath, section: 0)
//        let cell = tableView.cellForRow(at: indexpath) as? CameraListTableViewCell
//        
        
        print(cellArray)
        for index in 0 ..< cellArray.count
        {
            if (cellArray[index].participant == participant)
            {
                let cell = cellArray[index]
                let renderer = TVIVideoViewRenderer.init()
                videoTrack.addRenderer(renderer)
                renderer.view.frame = cell.cameraView.bounds
                renderer.view.contentMode = .scaleAspectFill
                cell.cameraView.addSubview(renderer.view)
                tableIndex += 1;
                break;
            }
        }
        
        
        
        
        
//        if (.participant == participant)
//            {
//                let renderer = TVIVideoViewRenderer.init()
//                
//                videoTrack.addRenderer(renderer)
//                renderer.view.frame = cell.cameraView.bounds
//                renderer.view.contentMode = .scaleAspectFill
//                cell.cameraView.addSubview(renderer.view)
//
//                
//            }
//        }
        
        
    }
    
    func participant(_ participant: TVIParticipant, removedVideoTrack videoTrack: TVIVideoTrack) {
        logMessage(messageText: "Participant \(participant.identity) removed video track")
        
        if (cellArray[tableIndex].participant == participant) {
            videoTrack.detach((cellArray[tableIndex].cameraView)!)
        }
    }
    
    func participant(_ participant: TVIParticipant, addedAudioTrack audioTrack: TVIAudioTrack) {
        logMessage(messageText: "Participant \(participant.identity) added audio track")
        
    }
    
    func participant(_ participant: TVIParticipant, removedAudioTrack audioTrack: TVIAudioTrack) {
        logMessage(messageText: "Participant \(participant.identity) removed audio track")
    }
    
    func participant(_ participant: TVIParticipant, enabledTrack track: TVITrack) {
        var type = ""
        if (track is TVIVideoTrack) {
            type = "video"
        } else {
            type = "audio"
        }
        logMessage(messageText: "Participant \(participant.identity) enabled \(type) track")
    }
    
    func participant(_ participant: TVIParticipant, disabledTrack track: TVITrack) {
        var type = ""
        if (track is TVIVideoTrack) {
            type = "video"
        } else {
            type = "audio"
        }
        logMessage(messageText: "Participant \(participant.identity) disabled \(type) track")
    }
}
*/
