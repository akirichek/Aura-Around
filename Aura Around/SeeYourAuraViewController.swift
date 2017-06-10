//
//  SeeYourAuraViewController.swift
//  Aura Around
//
//  Created by Artem Kirichek on 6/5/17.
//  Copyright © 2017 Artem Kirichek. All rights reserved.
//

import UIKit

class SeeYourAuraViewController: UIViewController {

    var captureSessionController: CaptureSessionController!
    
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup "Visage" with a camera-position (iSight-Camera (Back), FaceTime-Camera (Front)) and an optimization mode for either better feature-recognition performance (HighPerformance) or better battery-life (BatteryLife)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSessionController = CaptureSessionController(withView: self.cameraView)
        
        //You need to call "beginFaceDetection" to start the detection, but also if you want to use the cameraView.
//        captureSessionController.beginFaceDetection()
        
        //This is a very simple cameraView you can use to preview the image that is seen by the camera.
//        let cameraView = captureSessionController.cameraView
//        self.view.addSubview(cameraView)
    }
}
