//
//  QRCodeReader.swift
//  GhGist_FvComment
//
//  Created by Philliph on 14/07/18.
//  Copyright © 2018 Philliph. All rights reserved.
//  Modified for swift 4.0 from https://github.com/danielCarlosCE/aguente  - 2017

import AVFoundation

class QRCodeReader : NSObject {
    
    fileprivate(set) var videoPreview = CALayer()
    fileprivate var captureSession: AVCaptureSession?
    fileprivate var didRead: ((String) -> Void)?
    
    override init() {
        
        super.init()
        
        //Make sure the device can handle video
        guard let defaultVideoDevice = AVCaptureDevice.default(for: .video),
            let deviceInput = try? AVCaptureDeviceInput(device: defaultVideoDevice) else { return }
        
        //session
        captureSession = AVCaptureSession()
        
        //input
        captureSession?.addInput(deviceInput)

        //output
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        //interprets qr codes only
       
        //Core QR code
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        guard let unCapSession = captureSession else { return }
        
        let captureVideoPreview = AVCaptureVideoPreviewLayer(session: unCapSession )
        captureVideoPreview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoPreview = captureVideoPreview
    }
    
}

extension QRCodeReader : QRCodeReaderProtocol {
    
    func startReading(completion: @escaping (String) -> Void) {
        self.didRead = completion
        captureSession?.startRunning()
    }
    
    func stopReading() {
        captureSession?.stopRunning()
    }
}


extension QRCodeReader: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard let readableCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let code = readableCode.stringValue else {
                return
        }
        
        //Vibrate the phone
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        stopReading()
        
        didRead?(code)
        
    }
}

