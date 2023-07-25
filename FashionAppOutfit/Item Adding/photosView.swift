//
//  photosView.swift
//  FashionAppOutfit
//
//  Created by Aly Salman on 24/05/23.
//

import Foundation
import UIKit
import SwiftUI

protocol PhotoPickerDelegate: AnyObject {
    func didSelectPhoto(_ photo: UIImage)
}

class PhotoPickerView: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    weak var delegate: PhotoPickerDelegate?
    
    private let imagePicker = UIImagePickerController()
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Take Photo", for: .normal)
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        view.addSubview(cameraButton)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true

    }
    
    func showPhotoPicker() {
        let alertController = UIAlertController(title: "Choose a photo", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.showCameraPicker()
        }
        alertController.addAction(cameraAction)
        
        let libraryAction = UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.showLibraryPicker()
        }
        alertController.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showCameraPicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(message: "Camera is not available.")
            return
        }
        
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func showLibraryPicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            showAlert(message: "Photo library is not available.")
            return
        }
        
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            delegate?.didSelectPhoto(image)
        }
    }
    @IBAction func pickPhotoButtonTapped(_ sender: UIButton) {
        let photoPicker = PhotoPickerView()
        photoPicker.showPhotoPicker()
    }
    
    @objc private func openCamera() {
        showCameraPicker()
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
struct ImagePickerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias SourceType = UIImagePickerController.SourceType
    
    let sourceType: SourceType
    let completionHandler: (UIImage?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completionHandler: completionHandler)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No need to update the view controller
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let completionHandler: (UIImage?) -> Void
        
        init(completionHandler: @escaping (UIImage?) -> Void) {
            self.completionHandler = completionHandler
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                completionHandler(image)
            } else {
                completionHandler(nil)
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completionHandler(nil)
            picker.dismiss(animated: true, completion: nil)
        }
    }
}


