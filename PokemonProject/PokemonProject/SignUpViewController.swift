//
//  SignUpViewController.swift
//  PokemonProject
//
//  Created by user147489 on 12/2/18.
//  Copyright © 2018 Rathin Chopra. All rights reserved.
//

import UIKit
import Firebase
import WebKit

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    var picker:UIImagePickerController?=UIImagePickerController()
    var photoURL:URL? = nil
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    // MARK: Initialize firestore variable
    // ------------------------------------
    var db:Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email.delegate = self
        password.delegate = self
        profileImage.isUserInteractionEnabled = true
        profileImage.contentMode = UIView.ContentMode.scaleAspectFit
        showToast(controller: self, message: "Click on the image to add a profile picture", seconds: 2.0)
        picker?.delegate = self
        
        db = Firestore.firestore()
        
        // OPTIONAL:  Required when dealing with dates that are stored in Firestore
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func  makeAlert(title:String, message:String) {
        
        //creating the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        //showing the alert on screen.
        self.present(alert, animated: true, completion: nil)
    }
    
    func showToast(controller: UIViewController, message : String, seconds: Double) {
        
        //making a timed  alert
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        //presenting the alert as a toast.
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
            if(seconds == 1.0){
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        let email = self.email.text!
        let password = self.password.text!
        
        // MARK: FB:  Try to create a user using Firebase Authentication
        // This is all boilerplate code copied and pasted from Firebase documentation
        Auth.auth().createUser(withEmail: email, password: password) {
            
            (user, error) in
            
            if (user != nil) {
                // 1. New user created!
                self.uploadImage()
                //self.makeAlert(title: "Account Created", message: (user?.user.email)!)
                self.showToast(controller: self, message : "Account created", seconds: 1.0)
                
            }
            else {
                // 1. Error when creating a user
                print("ERROR!")
                print(error?.localizedDescription)
                
                // 2. Show the error in the UI
                let errorMsg = error?.localizedDescription
                self.makeAlert(title: "Error", message: errorMsg!)
                
            }
        }
    }
    
    
    
    @IBAction func imagePressed(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.picker!.allowsEditing = false
            self.picker!.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(self.picker!, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let chosenImage =  info[UIImagePickerController.InfoKey.originalImage]
            as? UIImage else {
                return
        }
        profileImage.image = chosenImage
        profileImage.contentMode = .scaleAspectFit
        profileImage.image = chosenImage
        dismiss(animated: true, completion: nil)
        
        if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
            let imgName = imgUrl.lastPathComponent
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let localPath = documentDirectory?.appending(imgName)
            
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            let data = image.pngData()! as NSData
            data.write(toFile: localPath!, atomically: true)
            //let imageData = NSData(contentsOfFile: localPath!)!
            photoURL = URL.init(fileURLWithPath: localPath!)//NSURL(fileURLWithPath: localPath!)
            print("----------------------------------------")
            print(photoURL)
            print("------------------------------------------")
            
        }
        
    }
    
    func uploadImage(){
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // File located on disk
        let localFile = photoURL
        
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("images/\(email.text).jpg")
        
        
        
        // Upload the file to the path "images/rivers.jpg"
        if(localFile == nil){
            return
        }else{
        
            let uploadTask = riversRef.putFile(from: localFile!, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                riversRef.downloadURL { (url, error) in
                    if let error = error {
                        // Handle any errors
                    } else {
                        self.addImageURLToDatabase(values: url!)
                    }
                }
            }
        }
        
    }
    
    func addImageURLToDatabase(values:URL){
        guard let userEmail = Auth.auth().currentUser?.email else {
            return
        }
        
        db.collection("users").document().setData([
            "email": String(userEmail),
            "photoURL": values.absoluteString
            ])
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
