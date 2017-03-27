//
//  VBlogViewController.swift
//  deKKo
//
//  Created by YangSzu Kai on 2017/3/26.
//  Copyright © 2017年 ArcCotagent. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VBlogViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet weak var CollectionviewView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        CollectionviewView.delegate = self
        CollectionviewView.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = CollectionviewView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
     
        var aPlayer = AVPlayer()
        let moviePlayerController = AVPlayerViewController()
        
      
        aPlayer = AVPlayer(url: URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!)
        
        moviePlayerController.player = aPlayer
        moviePlayerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        moviePlayerController.view.sizeToFit()
       
        cell.addSubview(moviePlayerController.view)
 
       
        return cell
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
