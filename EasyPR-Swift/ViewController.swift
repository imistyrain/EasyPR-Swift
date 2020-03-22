//
//  ViewController.swift
//  EasyPR-Swift
//
//  Created by yanyu on 2019/7/28.
//  Copyright © 2019 yanyu. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    //var  imageView: UIImageView!
    
    fileprivate var session :AVCaptureSession? = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mainPath = Bundle.main.bundlePath
        OpenCVWrapper.setmodeldir(mainPath)
        // Do any additional setup after loading the view.
        imageView.frame = UIScreen.main.bounds.insetBy(dx: -44, dy: 0)
        initCapture()
    }
    
    func initCapture(){
        guard let devices = AVCaptureDevice.devices() as?[AVCaptureDevice] else{return}
        guard let device = devices.filter({$0.position == .back}).first else {return}
        guard let input = try? AVCaptureDeviceInput(device: device) else {return}
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
        output.alwaysDiscardsLateVideoFrames = true
        guard let session = session else { return }
        session.beginConfiguration()
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output){
            session.addOutput(output)
        }
        session.commitConfiguration()
        session.startRunning()
    }
}

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("could not get a pixel buffer")
            return
        }
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
        let image = CIImage(cvPixelBuffer: buffer).oriented(CGImagePropertyOrientation.right)
        let capturedImage = UIImage(ciImage: image)
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
        //let startTime = CFAbsoluteTimeGetCurrent()
        let resultImage = OpenCVWrapper.plateRecognize(capturedImage)
        //let endTime = CFAbsoluteTimeGetCurrent()
        //let cost=(endTime - startTime)*1000
        //debugPrint("\(cost) ms")
        //let resultImage=capturedImage
        DispatchQueue.main.async{
            self.imageView.image=resultImage
        }
    }
}
