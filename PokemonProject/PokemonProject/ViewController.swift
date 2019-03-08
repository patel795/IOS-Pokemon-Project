//
//  ViewController.swift
//  PokemonProject
//
//  Created by Rathin Chopra(991459347) & Deep Patel(991464575) & Navneet Singh(991462201) on 11/27/18.
//  Copyright © 2018 Rathin Chopra. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class ViewController: UIViewController, UITextFieldDelegate{

    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    var db:Firestore!
    var userPokeData = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        password.delegate = self
        email.delegate = self
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Pika")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        db = Firestore.firestore()
        
        // OPTIONAL:  Required when dealing with dates that are stored in Firestore
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This function is called when the user presses the back button in child view.
    //Then this view is taken from the stack.
    override func viewWillAppear(_ animated: Bool) {
        
        //clearing the text boxes.
        self.email.text = ""
        self.password.text = ""
    }

    func  makeAlert(title:String, message:String) {
        
        //creating the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        //showing the alert on screen.
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func loginPressed(_ sender: Any) {
        
        // UI: Get the email/password from the text boxes
        let email = self.email.text!
        let password = self.password.text!
        var userInDataBase = false
        
        // MARK: FB:  Try to sign the user in using Firebase Authentication
        // This is all boilerplate code copied and pasted from Firebase documentation
        Auth.auth().signIn(withEmail: email, password: password) {
            
            (user, error) in
            
            if (user != nil) {
                // 1. Found a user!
                print("User signed in! ")
                print("User id: \(user?.user.uid)")
                print("Email: \(user?.user.email)")
                
                
                self.db.collection("pokedata").getDocuments() {
                    (querySnapshot, err) in
                    
                    // MARK: FB - Boilerplate code to get data from Firestore
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("---------------------------------------------")
                            //print("\(document.documentID) => \(document.data())")
                            let data = document.data()
                            let currentUserEmail = user?.user.email
                            let currentUserData = "\(data["email"]!)"
                            if(currentUserData == currentUserEmail){
                                print(document.documentID)
                                self.userPokeData = data
                                userInDataBase = true
                            }
                        }
                        if(userInDataBase == true){
                            self.performSegue(withIdentifier: "segueGame", sender: nil)
                        }
                        else{
                            // 2. So send them to screen 2!
                            self.performSegue(withIdentifier: "segueA", sender: nil)
                        }
                    }
                }
            }
            else {
                // 1. A problem occured when looking up  the user
                // - doesn't meet password requirements
                // - user already exists
                print("ERROR!")
                print(error?.localizedDescription)
                
                // 2. Show the error in user interface
                let errorMsg = error?.localizedDescription
                self.makeAlert(title: "Error", message: errorMsg!)
            }
        }
    }
    
    // MARK: Navigation - prepare() function!
    // ----------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("going to next page")
        if(segue.identifier == "segueGame"){
            let gamePage = segue.destination as! GameViewController
            gamePage.userData = userPokeData
        }
    }
}

