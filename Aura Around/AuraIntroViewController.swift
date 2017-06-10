//
//  AuraIntroViewController.swift
//  Aura Around
//
//  Created by Artem Kirichek on 6/5/17.
//  Copyright © 2017 Artem Kirichek. All rights reserved.
//

import UIKit
import AVFoundation

class AuraIntroViewController: UIViewController {

    @IBOutlet weak var playerContainerView: UIView!
    var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        setupPlayer()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidPlayToEndTime),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        player.pause()
    }
    
    func playerDidPlayToEndTime(_ notification: Notification){
        DispatchQueue.main.async {
            self.player.seek(to: kCMTimeZero)
            self.player.play()
        }
    }
    
    func setupPlayer() {
        let path = Bundle.main.path(forResource: "Main_video_aura", ofType: "mp4")!
        let videoURL = URL(fileURLWithPath: path)
        player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.frame = self.playerContainerView.bounds
        self.playerContainerView.layer.addSublayer(playerLayer)
        player.play()
    }
}
