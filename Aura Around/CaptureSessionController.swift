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
    var square: UIImage! = UIImage(named: "square_box")!
    
    init(withView view: UIView) {
        cameraView = view
        super.init()
        self.captureSetup()
        
        var faceDetectorOptions : [String : AnyObject]?
        faceDetectorOptions = [CIDetectorAccuracy : CIDetectorAccuracyHigh as AnyObject]
        self.faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: faceDetectorOptions)
    }
    
    //MARK: SETUP OF VIDEOCAPTURE
//    func beginFaceDetection() {
//        self.captureSession.startRunning()
//    }
//    
//    func endFaceDetection() {
//        self.captureSession.stopRunning()
//    }
    
    fileprivate func captureSetup () {
//        var captureError : NSError?
//        var captureDevice : AVCaptureDevice!
//        
//        for testedDevice in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo){
//            if ((testedDevice as AnyObject).position == AVCaptureDevicePosition.front) {
//                captureDevice = testedDevice as! AVCaptureDevice
//            }
//        }
//        
//        if (captureDevice == nil) {
//            captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
//        }
//        
//        var deviceInput : AVCaptureDeviceInput?
//        do {
//            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
//        } catch let error as NSError {
//            captureError = error
//            deviceInput = nil
//        }
//        captureSession.sessionPreset = AVCaptureSessionPresetHigh
//        
//        if (captureError == nil) {
//            if (captureSession.canAddInput(deviceInput)) {
//                captureSession.addInput(deviceInput)
//            }
//            
//            self.videoDataOutput = AVCaptureVideoDataOutput()
//            self.videoDataOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)]
//            self.videoDataOutput!.alwaysDiscardsLateVideoFrames = true
//            self.videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue", attributes: [])
//            self.videoDataOutput!.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue!)
//            
//            if (captureSession.canAddOutput(self.videoDataOutput)) {
//                captureSession.addOutput(self.videoDataOutput)
//            }
//        }
//        
//        cameraView.frame = UIScreen.main.bounds
//        
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer?.frame = UIScreen.main.bounds
//        previewLayer?.videoGravity = AVLayerVideoGravityResize
//        cameraView.layer.addSublayer(previewLayer!)
//        self.captureSession.startRunning()
        
//        var captureDevice : AVCaptureDevice!
//
//        for testedDevice in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo){
//            if ((testedDevice as AnyObject).position == AVCaptureDevicePosition.front) {
//                captureDevice = testedDevice as! AVCaptureDevice
//            }
//        }
        
        let session : AVCaptureSession = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPreset640x480
        
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
    }
    
    var options : [String : AnyObject]?
    var faceBox: UIView = UIView()
    
    //MARK: CAPTURE-OUTPUT/ANALYSIS OF FACIAL-FEATURES
//    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
//        
//        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//        let opaqueBuffer = Unmanaged<CVImageBuffer>.passUnretained(imageBuffer!).toOpaque()
//        let pixelBuffer = Unmanaged<CVPixelBuffer>.fromOpaque(opaqueBuffer).takeUnretainedValue()
//        let sourceImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
//        DispatchQueue.main.sync {
//            //let sourceImage = CIImage(image: self.imageView.image!)!
//            self.options = [CIDetectorSmile : true as AnyObject, CIDetectorEyeBlink: true as AnyObject, CIDetectorImageOrientation : 6 as AnyObject]
//            
//            let faces = self.faceDetector!.features(in: sourceImage, options: self.options) as! [CIFaceFeature]
//            
//            if (faces.count != 0) {
//                
//                for i in 0..<faces.count {
//                    let face = faces[i]
//                    
//                    print("1 bounds: \(face.bounds) angle: \(CGFloat(face.faceAngle))")
//                    //DispatchQueue.main.sync {
//                        let ciImageSize = sourceImage.extent.size
//                        var transform = CGAffineTransform(scaleX: 1, y: -1)
//                        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
//                        // Apply the transform to convert the coordinates
//                        var faceViewBounds = face.bounds.applying(transform)
//                        
//                        // Calculate the actual position and size of the rectangle in the image view
//                        let viewSize = cameraView.bounds.size
//                        let scale = min(viewSize.width / ciImageSize.width,
//                                        viewSize.height / ciImageSize.height)
//                        let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
//                        let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
//                        
//                        faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
//                        faceViewBounds.origin.x += offsetX
//                        faceViewBounds.origin.y += offsetY
//                        
//                        //let faceBox = UIView(frame: faceViewBounds)
//                        
//                        
//                        
//                        
//                        
//                        print("2 bounds: \(faceViewBounds) angle: \(CGFloat(face.faceAngle))")
//                        
//                        
//                        faceBox.frame = faceViewBounds
//                        
//                        if faceBox.superview == nil {
//                            cameraView.addSubview(faceBox)
//                            
//                            faceBox.layer.borderWidth = 3
//                            faceBox.layer.borderColor = UIColor.red.cgColor
//                            faceBox.backgroundColor = UIColor.clear
//                        }
//                    //}
//                    
//                    
//    //                faceBounds = feature.bounds
//    //                
//    //                if (feature.hasFaceAngle) {
//    //                    
//    //                    if (faceAngle != nil) {
//    //                        faceAngleDifference = CGFloat(feature.faceAngle) - faceAngle!
//    //                    } else {
//    //                        faceAngleDifference = CGFloat(feature.faceAngle)
//    //                    }
//    //                    
//    //                    faceAngle = CGFloat(feature.faceAngle)
//    //                }
//                }
//            } else {
//                faceBox.removeFromSuperview()
//            }
//        }
//    }
    
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
            self.drawFaceBoxesForFeatures(features as NSArray, clap: clap)
        })
    }
    
    // called asynchronously as the capture output is capturing sample buffers, this method asks the face detector (if on)
    // to detect features and for each draw the red square in a layer and set appropriate orientation
    func drawFaceBoxesForFeatures(_ features : NSArray, clap : CGRect) {
        
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
        
        for ff in features as! [CIFaceFeature] {
            
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
            
            
            
            print("2drawFaceBoxesForFeatures \(faceRect)")
            // scale coordinates so they fit in the preview box, which may be scaled
            let widthScaleBy = previewBox.size.width / clap.size.height
            let heightScaleBy = previewBox.size.height / clap.size.width
            faceRect.size.width *= widthScaleBy
            faceRect.size.height *= heightScaleBy
            faceRect.origin.x *= widthScaleBy
            faceRect.origin.y *= heightScaleBy
            print("3drawFaceBoxesForFeatures \(faceRect)")
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
                featureLayer?.contents = square.cgImage
                featureLayer?.name = "FaceLayer"
                previewLayer.addSublayer(featureLayer!)
            }
            
            featureLayer?.frame = faceRect
            
            currentFeature += 1
        }
        
        CATransaction.commit()
    }
    
    func videoPreviewBoxForGravity(_ gravity : NSString, frameSize : CGSize, apertureSize : CGSize) -> CGRect {
        var videoBox : CGRect = CGRect.zero
        videoBox.size = frameSize
        videoBox.origin.x = (frameSize.width - frameSize.width) / 2;
        videoBox.origin.y = (frameSize.height - frameSize.height) / 2;
        
        return videoBox
    }
}
