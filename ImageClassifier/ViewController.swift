//
//  ViewController.swift
//  ImageClassifier
//
//  Created by Anmol Sakarda on 7/21/19.
//  Copyright © 2019 Anmol Sakarda. All rights reserved.
//

import UIKit
import AVKit
import Vision



class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let identifierLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "";
        return label
    }()
    
    

    

    override func viewDidLoad() {
        
        let captureImage = AVCaptureSession()
        captureImage.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureImage.addInput(input)
        
        captureImage.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureImage)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let imageOutput = AVCaptureVideoDataOutput()
        imageOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureImage.addOutput(imageOutput)
        
        
        
        drawObjectLabel()
        //setupClassifyButton()
        
        
    }
    
    
    
    
    fileprivate func drawObjectLabel() {
        view.addSubview(identifierLabel)
        identifierLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        identifierLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        identifierLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        identifierLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        

        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
           
            
            if(self.classify.isSelected) {
                if(firstObservation.confidence > 0.7) {
                    DispatchQueue.main.async {
                        self.identifierLabel.text = "\(firstObservation.identifier)"
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.identifierLabel.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
                    }
                }
                
            }
            else {
                DispatchQueue.main.async {
                    self.identifierLabel.text = ""
                }
            }
            
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    
    
    @IBOutlet weak var classify: UIButton!
    
    @IBAction func classifyButton(_ sender: UIButton) {
        classify.isSelected = !classify.isSelected
        if(classify.isSelected) {
            classify.setTitle("Stop", for: .normal)
        }
        else {
            classify.setTitle("Classify", for: .normal)
        }
    }
    
    
   
    
    
}

