//
//  ViewController.swift
//  WhatFlower
//
//  Created by Marcus Y. Kim on 9/22/20.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .camera
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            guard let convertedCIImage = CIImage(image: userPickedImage) else {
                fatalError("can't convert to CIImage")
            }
            
            detect(image: convertedCIImage)
            
            imageView.image = userPickedImage
            
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Failed to import model")
        }
        
        let request = VNCoreMLRequest(model: model) {(request, error) in
            
            let classification = request.results?.first as? VNClassificationObservation
            
            self.navigationItem.title = classification?.identifier.capitalized
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
        
        try handler.perform([request])
        } catch {
        print(error)
        }
    }
    
    
    
    


@IBAction func cameraTapped(_ sender: UIBarButtonItem) {
    
    present(picker, animated: true, completion: nil)
    
}

}

