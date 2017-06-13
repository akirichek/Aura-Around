//
//  CaptureSessionController.swift
//  Aura Around
//
//  Created by Artem Kirichek on 6/5/17.
//  Copyright © 2017 Artem Kirichek. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation
import ImageIO

class CaptureSessionController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var cameraView : UIView
    var previewLayer : AVCaptureVideoPreviewLayer!
    var stillImageOutput : AVCaptureStillImageOutput!
    
    //Private variables that cannot be accessed by other classes in any way.
    fileprivate var faceDetector : CIDetector!
    fileprivate var videoDataOutput : AVCaptureVideoDataOutput!
    fileprivate var videoDataOutputQueue : DispatchQueue!
    fileprivate var captureSession : AVCaptureSession =  AVCaptureSession()
    fileprivate let notificationCenter : NotificationCenter = NotificationCenter.default
    var auraImages: [UIImage]!
    var currentAuraImageIndex: Int = 0
    
    init(withView view: UIView) {
        cameraView = view
        super.init()
        
        let detectorOptions = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorTracking: true] as [String : Any]
        faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: detectorOptions)
        
        self.setupAuraImages()
        self.captureSetup()
    }
    
    fileprivate func captureSetup () {
        let session : AVCaptureSession = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPreset1280x720
        
        // Select a video device, make an input
        let captureDevice : AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let deviceInput : AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: captureDevice)
        
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
        
        stillImageOutput = AVCaptureStillImageOutput()
        
        // Make a video data output
        videoDataOutput = AVCaptureVideoDataOutput()
        // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
        let rgbOutputSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCMPixelFormat_32BGRA as UInt32)]
        
        videoDataOutput.videoSettings = rgbOutputSettings
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue", attributes: [])
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        videoDataOutput.connection(withMediaType: AVMediaTypeVideo).isEnabled = false
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.backgroundColor = UIColor.black.cgColor
        previewLayer.videoGravity = AVLayerVideoGravityResize
        let rootLayer : CALayer = cameraView.layer
        rootLayer.masksToBounds = true
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
        session.startRunning()
        
        
        
        var desiredPosition : AVCaptureDevicePosition
        desiredPosition = AVCaptureDevicePosition.front
        
        for d in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice] {
            
            if d.position == desiredPosition {
                
                previewLayer.session.beginConfiguration()
                
                let input : AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: d)
                
                for oldInput in previewLayer.session.inputs as! [AVCaptureInput] {
                    previewLayer.session.removeInput(oldInput)
                }
                
                previewLayer.session.addInput(input)
                previewLayer.session.commitConfiguration()
            }
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // got an image
        let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let attachments : CFDictionary = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, pixelBuffer, CMAttachmentMode( kCMAttachmentMode_ShouldPropagate))!
        
        let ciImage : CIImage = CIImage(cvPixelBuffer: pixelBuffer, options: attachments as? [String : AnyObject])


        
        let imageOptions : NSDictionary = [CIDetectorImageOrientation : 6, CIDetectorSmile : true, CIDetectorEyeBlink : true]
        
        let features = faceDetector.features(in: ciImage, options: imageOptions as? [String : AnyObject])
        
        // get the clean aperture
        // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
        // that represents image data valid for display.
        let fdesc : CMFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)!
        let clap : CGRect = CMVideoFormatDescriptionGetCleanAperture(fdesc, false)
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.drawFaceBoxesForFeatures(features as! [CIFaceFeature], clap: clap)
        })
    }
    
    // called asynchronously as the capture output is capturing sample buffers, this method asks the face detector (if on)
    // to detect features and for each draw the red square in a layer and set appropriate orientation
    func drawFaceBoxesForFeatures(_ features : [CIFaceFeature], clap : CGRect) {
        
        let sublayers : NSArray = previewLayer.sublayers! as NSArray
        let sublayersCount : Int = sublayers.count
        var currentSublayer : Int = 0
        //        var featuresCount : Int = features.count
        var currentFeature : Int = 0
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // hide all the face layers
        for layer in sublayers as! [CALayer] {
            if (layer.name != nil && layer.name == "FaceLayer") {
                layer.isHidden = true
            }
        }
        
        if ( features.count == 0) {
            CATransaction.commit()
            return
        }
        
        let parentFrameSize : CGSize = cameraView.frame.size
        let gravity : NSString = previewLayer.videoGravity as NSString
        
        let previewBox : CGRect = videoPreviewBoxForGravity(gravity, frameSize: parentFrameSize, apertureSize: clap.size)
        
        let ff = features.first!
        var faceRect : CGRect = ff.bounds
        
        print("1drawFaceBoxesForFeatures \(faceRect)")
        // flip preview width and height
        var temp : CGFloat = faceRect.width
        faceRect.size.width = faceRect.height
        faceRect.size.height = temp
        temp = faceRect.origin.x
        faceRect.origin.x = faceRect.origin.y
        faceRect.origin.y = temp
        
        
        //            originalFrame = CGRectOffset(originalFrame, previewBox.origin.x + previewBox.size.width - originalFrame.size.width - (originalFrame.origin.x * 2), previewBox.origin.y);
        
        
        
        print("2drawFaceBoxesForFeatures \(cameraView.frame)")
        // scale coordinates so they fit in the preview box, which may be scaled
        let widthScaleBy = previewBox.size.width / clap.size.height
        let heightScaleBy = previewBox.size.height / clap.size.width
        faceRect.size.width *= widthScaleBy
        faceRect.size.height *= heightScaleBy
        faceRect.origin.x *= widthScaleBy
        faceRect.origin.y *= heightScaleBy
        print("3drawFaceBoxesForFeatures \(widthScaleBy) \(heightScaleBy)")
        faceRect = faceRect.offsetBy(dx: previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), dy: previewBox.origin.y)
        print("4 drawFaceBoxesForFeatures \(faceRect)")
        var featureLayer : CALayer? = nil
        // re-use an existing layer if possible
        while (featureLayer == nil) && (currentSublayer < sublayersCount) {
            
            let currentLayer : CALayer = sublayers.object(at: currentSublayer) as! CALayer
            currentSublayer += 1
            
            if currentLayer.name == nil {
                continue
            }
            let name : NSString = currentLayer.name! as NSString
            if name.isEqual(to: "FaceLayer") {
                featureLayer = currentLayer;
                currentLayer.isHidden = false
            }
        }
        
        // create a new one if necessary
        if featureLayer == nil {
            featureLayer = CALayer()
            featureLayer?.name = "FaceLayer"
            previewLayer.addSublayer(featureLayer!)
        }
        
        featureLayer?.contents = auraImages[currentAuraImageIndex].cgImage
        currentAuraImageIndex += 1
        if currentAuraImageIndex >= auraImages.count {
            currentAuraImageIndex = 0
        }
        featureLayer?.frame = auraFrame(withFaceRect: faceRect)
        
        print("5 drawFaceBoxesForFeatures \(auraFrame(withFaceRect: faceRect))")
        currentFeature += 1
        
        CATransaction.commit()
    }
    
    func auraFrame(withFaceRect faceRect: CGRect) -> CGRect {
        let standartFaceSize = CGSize(width: 210, height: 275)
        let scale = faceRect.width / standartFaceSize.width
        let width = 320 * scale
        let height = 568 * scale
        
        let originX: CGFloat = faceRect.origin.x - ((width - faceRect.width) / 2) - (10 * scale)
        let originY: CGFloat = faceRect.origin.y - ((height - faceRect.height) / 2) - (100 * scale)
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    func videoPreviewBoxForGravity(_ gravity : NSString, frameSize : CGSize, apertureSize : CGSize) -> CGRect {
        var videoBox : CGRect = CGRect.zero
        videoBox.size = frameSize
        videoBox.origin.x = (frameSize.width - frameSize.width) / 2;
        videoBox.origin.y = (frameSize.height - frameSize.height) / 2;
        
        return videoBox
    }
    
    func setupAuraImages() {
        var auraImages: [UIImage] = []
        for i in 0..<47 {
            var number = ""
            if i < 10 {
                number += "0"
            }
            number += "\(i)"
            auraImages.append(UIImage(named: "green_000\(number)")!)
        }
        self.auraImages = auraImages
    }
}
