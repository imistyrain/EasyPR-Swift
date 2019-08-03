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
    fileprivate var session :AVCaptureSession? = AVCaptureSession()
    fileprivate var videoOutput: AVCaptureOutput?
    fileprivate var videoInput: AVCaptureDeviceInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mainPath=Bundle.main.bundlePath
        //print(mainPath)
        OpenCVWrapper.setmodeldir(mainPath)
        // Do any additional setup after loading the view.
        setupVideoInputOutput()
        //setupPreviewLayer()
        session?.startRunning()
    }
}

extension ViewController{
    fileprivate func setupVideoInputOutput(){
        if session == nil {
            session=AVCaptureSession()
        }
        guard let devices = AVCaptureDevice.devices() as?[AVCaptureDevice] else{return}
        guard let device = devices.filter({$0.position == .back}).first else {return}
        guard let input = try? AVCaptureDeviceInput(device: device) else {return}
        self.videoInput = input
        //2.添加视频的输出
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
        /// 是否直接丢弃处理旧帧时捕获的新帧,默认为True,如果改为false会大幅提高内存使用
        output.alwaysDiscardsLateVideoFrames = true
        addInputOutput2session(input, output)
        videoOutput = output
    }
    fileprivate func addInputOutput2session(_ input: AVCaptureInput ,_ output: AVCaptureOutput){
        guard let session = session else { return }
        session.beginConfiguration()
        //3.添加输入输出
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output){
            session.addOutput(output)
        }
        
        //完成配置
        session.commitConfiguration()
    }
}

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // 将捕捉到的image buffer 转换成 UIImage.
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
