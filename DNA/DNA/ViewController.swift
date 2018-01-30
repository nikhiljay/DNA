//
//  ViewController.swift
//  NCBI
//
//  Created by Nikhil D'Souza on 9/2/17.
//  Copyright © 2017 Nikhil D'Souza. All rights reserved.
//

import UIKit
import Alamofire
import TesseractOCR

extension String {
    func charAt(at: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: at)
        return self[charIndex]
    }
}

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, G8TesseractDelegate {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var sequenceTextField: UITextField!
    @IBOutlet weak var methodPickerView: UIPickerView!
    @IBOutlet weak var outputTextView: UITextView!
    var imagePicker = UIImagePickerController()
    
    var pickerData = ["Complement", "Transcribe", "Translate", "Reverse"]
    var url = "http://192.168.11.25:8000/data"
    //DigitalOcean = 104.131.156.241
    //Computer = http://192.168.11.25:8000/data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.methodPickerView.delegate = self
        self.methodPickerView.dataSource = self
        self.sequenceTextField.delegate = self
        self.imagePicker.delegate = self
    }

    func getData() {
        var k = 1
        while k <= 5 {
            self.outputTextView.text = ""
            
            let parameters: Parameters = [
                "strand": sequenceTextField.text ?? "",
                "method": pickerData[methodPickerView.selectedRow(inComponent: 0)]
            ]
            
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            
            Alamofire.request(url).responseJSON { response in
                if let json = response.result.value {
                    for data in json as! [String: AnyObject] {
                        if self.methodPickerView.selectedRow(inComponent: 0) == 2 { //if translate
                            let output = data.value as! String
                            self.outputTextView.text = ""
                            for i in 0...output.characters.count-1 {
                                let protein = getProtein(abbreviation: output.charAt(at: i)) //convert char to protein
                                if i == output.count-1 {
                                    self.outputTextView.text = self.outputTextView.text.appendingFormat(protein)
                                } else {
                                    self.outputTextView.text = self.outputTextView.text.appendingFormat(protein + "-")
                                }
                            }
                        } else {
                            self.outputTextView.text = "\(data.value)"
                        }
                    }
                }
            }
            k = k + 1
        }
    }
    
    @IBAction func getResultButtonPressed(_ sender: Any) {
        getData()
    }

    //MARK: Image Picker Controller
    @IBAction func pictureButtonPressed(_ sender: Any) {
        imagePicker.allowsEditing = true
        
        let alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { UIAlertAction in
            self.openCamera()
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default){ UIAlertAction in
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { UIAlertAction in }
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            alert.addAction(cameraAction)
        }
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let scaledImage = scaleImage(image: image!, maxDimension: 640)
        
        if let tesseract = G8Tesseract(language: "eng") {
            if methodPickerView.selectedRow(inComponent: 0) == 2 {
                tesseract.charWhitelist = "AUGC"
            } else {
                tesseract.charWhitelist = "AGTC"
            }
            tesseract.maximumRecognitionTime = 60
            tesseract.image = scaledImage.g8_blackAndWhite()
            tesseract.recognize()
            
            let recognizedText = String(tesseract.recognizedText.characters.filter{!" \n\t\r".characters.contains($0)})
            print("Recognized text: \(recognizedText)")
            sequenceTextField.text = recognizedText
            
            getData()
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print("\(tesseract.progress) %")
    }

    //MARK: UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    //MARK: UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sequenceTextField.resignFirstResponder()
        getData()
        return true
    }
}

