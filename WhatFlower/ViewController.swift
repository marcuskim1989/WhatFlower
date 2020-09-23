//
//  ViewController.swift
//  WhatFlower
//
//  Created by Marcus Y. Kim on 9/22/20.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    
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
            
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError("Could not classify image.")
            }
            
            self.navigationItem.title = classification.identifier.capitalized
            
            self.requestInfo(flowerName: classification.identifier)
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
        
        try handler.perform([request])
        } catch {
        print(error)
        }
    }
    
    
    
    func requestInfo(flowerName: String) {
        
        let parameters: [String:String] = [

        "format": "json",
        "action": "query",
        "prop" : "extracts",
        "exintro": "",
        "explaintext": "",
        "titles": flowerName,
            "indexpageids": "",
        "redirects": "1"

        ]
        
        AF.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .success:
                   print("got the wikipedia info")
                print(response.result)
                
                let flowerJSON: JSON = JSON(response.result)
                
                let pageid = flowerJSON["query"]["pageid"][0].stringValue
                
                let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
                
            case .failure:
                    print("did not get the wikipedia info")
                   
               
            }
        }
    }


@IBAction func cameraTapped(_ sender: UIBarButtonItem) {
    
    present(picker, animated: true, completion: nil)
    
}

}

