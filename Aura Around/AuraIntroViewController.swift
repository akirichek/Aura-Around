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
   
    var videoPlayer: AVPlayer!
    var audioPlayer: AVQueuePlayer!
    var audioFileNames: [String] = ["Hi", "Aura Contains", "Number into Color"]
    var currentAudioFileIndex: Int = 0
    var theNumber: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        if videoPlayer == nil {
            setupVideoPlayer()
            setupAudioPlayer()
        }
        
        videoPlayer.play()
        audioPlayer.play()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(videoPlayerDidPlayToEndTime),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: videoPlayer.currentItem)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        videoPlayer.pause()
        audioPlayer.pause()
    }
    
    func videoPlayerDidPlayToEndTime(_ notification: Notification) {
        DispatchQueue.main.async {
            self.videoPlayer.seek(to: kCMTimeZero)
            self.videoPlayer.play()
        }
    }
    
    func setupVideoPlayer() {
        let path = Bundle.main.path(forResource: "Main_video_aura", ofType: "mp4")!
        let videoURL = URL(fileURLWithPath: path)
        videoPlayer = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.frame = self.playerContainerView.bounds
        self.playerContainerView.layer.addSublayer(playerLayer)
    }
    
    func setupAudioPlayer() {
        let playerItems = [AVPlayerItem(url: Bundle.main.url(forResource: "Hi", withExtension: "mp3")!),
                           AVPlayerItem(url: Bundle.main.url(forResource: "Aura Contains", withExtension: "mp3")!),
                           AVPlayerItem(url: Bundle.main.url(forResource: "Number into Color", withExtension: "mp3")!),
                           AVPlayerItem(url: Bundle.main.url(forResource: "\(theNumber!)", withExtension: "mp3")!),
                           AVPlayerItem(url: Bundle.main.url(forResource: AuraColors(rawValue: theNumber)!.description, withExtension: "mp3")!)]
        audioPlayer = AVQueuePlayer(items: playerItems)
    }
    
    @IBAction func playAgainButtonClicked(_ sender: UIBarButtonItem) {
        setupAudioPlayer()
        audioPlayer.play()
    }
}
