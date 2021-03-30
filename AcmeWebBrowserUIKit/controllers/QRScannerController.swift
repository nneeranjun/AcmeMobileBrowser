//
//  QRCodeScanner.swift
//  AcmeWebBrowserUIKit
//
//  Created by Nilay Neeranjun on 3/29/21.
//

import AVFoundation
import UIKit

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    weak var delegate: ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded")
        
        if !isCameraEnabled() {
            requestCameraAccess()
        }

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("can't do video cap device")
            failed()
            return
        }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            print("doesnt support")
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("cant")
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
    
    func isCameraEnabled() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in }
    }
    
    func failed() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
                
            }))
            self.present(ac, animated: false)
            self.captureSession = nil
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }

    func found(code: String) {
        if code.isValidURL {
            let newTab = Tab(url: code, type: .normal)
            delegate.addNewTab(newTab)
            dismiss(animated: true, completion: nil)
        } else {
            let invalidQRCodeURLAlert = UIAlertController(title: "Invalid QR Code URL", message: "Please scan a QR code with a valid URL", preferredStyle: UIAlertController.Style.alert)
            invalidQRCodeURLAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { [self] _ in
                if (!(captureSession?.isRunning ?? false)) {
                    captureSession.startRunning()
                }
            }))
            present(invalidQRCodeURLAlert, animated: true, completion: nil)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
