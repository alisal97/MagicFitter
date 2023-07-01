//
//  camView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 23/05/23.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI

class CamView: UIViewController, ObservableObject {
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var captureButton: UIButton!
    var didCaptureImage: ((UIImage) -> Void)?
    private var captureDevice: AVCaptureDevice?
    private var currentPosition: AVCaptureDevice.Position = .back



    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCaptureSession()
        setupUI()
    }
    
    private func setupUI() {
         // Create a capture button
        self.captureButton = UIButton(type: .system)
        captureButton.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = captureButton.frame.width / 2
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)

        // Position the capture button using Auto Layout constraints
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            captureButton.widthAnchor.constraint(equalToConstant: 80), // Set the width constraint
            captureButton.heightAnchor.constraint(equalToConstant: 80) // Set the height constraint
        ])

        captureButton.transform = CGAffineTransform(scaleX: 1, y: 1) // Remove the scaling transform

         // Create a close button
         let closeButton = UIButton(type: .system)
         closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
         closeButton.tintColor = .white
         closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
         closeButton.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(closeButton)

         // Position the close button using Auto Layout constraints
         NSLayoutConstraint.activate([
             closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
             closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
         ])
        
        
        let switchButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 35)
        switchButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera", withConfiguration: config), for: .normal)
        switchButton.tintColor = .white
        switchButton.addTarget(self, action: #selector(switchButtonTapped), for: .touchUpInside)
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchButton)

        // Position the camera switch button using Auto Layout constraints
        NSLayoutConstraint.activate([
            switchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            switchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

     }
    @objc private func switchButtonTapped() {
        // Find the opposite camera position
        let oppositePosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back

        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        guard let newCaptureDevice = discoverySession.devices.first(where: { $0.position == oppositePosition }) else {
            print("No video capture devices available")
            return
        }

        // Create a new input with the opposite capture device
        guard let newInput = try? AVCaptureDeviceInput(device: newCaptureDevice) else {
            print("Failed to create new input")
            return
        }

        // Begin configuration
        captureSession?.beginConfiguration()

        // Remove existing inputs
        captureSession?.inputs.forEach { captureSession?.removeInput($0) }

        // Add the new input to the capture session
        if captureSession?.canAddInput(newInput) == true {
            captureSession?.addInput(newInput)
        }

        // Update the current capture device and position
        captureDevice = newCaptureDevice
        currentPosition = oppositePosition

        // Commit configuration
        captureSession?.commitConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Re-enable idle timer when the app goes into the background or is closed
        UIApplication.shared.isIdleTimerDisabled = false
    }

    private func prepareCaptureSession() {
        let captureSession = AVCaptureSession()

        // Select a back camera, make an input.
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }

        captureSession.addInput(input)

        let photoOutput = AVCapturePhotoOutput()
        captureSession.addOutput(photoOutput)


        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)

        self.captureSession = captureSession
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func captureButtonTapped() {
        guard let photoOutput = captureSession?.outputs.first(where: { $0 is AVCapturePhotoOutput }) as? AVCapturePhotoOutput else { return }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)

        let shutterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        shutterView.backgroundColor = UIColor.black
        shutterView.alpha = 0.0
        videoPreviewLayer?.addSublayer(shutterView.layer) // Add as sublayer to videoPreviewLayer

        UIView.animate(withDuration: 0.1, animations: {
            shutterView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.13, animations: {
                shutterView.alpha = 0.0
            }, completion: { _ in
                shutterView.removeFromSuperview()
            })
        })
    }
//    @objc private func openPhotoPicker() {
//        let photoPicker = PhotoPickerView()
//        photoPicker.delegate = self
//        present(photoPicker, animated: true, completion: nil)
//    }
}

extension CamView: PhotoPickerDelegate {
    func didSelectPhoto(_ photo: UIImage) {
        // Handle the selected photo
    }
}


extension CamView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }

        // Invoke the closure with the captured image
        didCaptureImage?(image)

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    
    }
}
