//
//  ProfileViewController.swift
//  PokemonProject
//
//  Created by user147489 on 11/27/18.
//  Copyright © 2018 Rathin Chopra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ChameleonFramework
import Firebase
import WebKit

class ProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pokemons:[String] = ["Choose Pokemon"]
    var pokeURL:[String] = ["Empty"]
    var values:String = ""
    var defaultMoves:[String] = []
    var upgradeableMoves:[String] = []
    var userPokeData = [String: Any]()
    
    // MARK: Initialize firestore variable
    // ------------------------------------
    var db:Firestore!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        db = Firestore.firestore()
        
        // OPTIONAL:  Required when dealing with dates that are stored in Firestore
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let URL = "https://pokeapi.co/api/v2/pokemon/"
        
        // ALAMOFIRE function: get the data from the website
        Alamofire.request(URL, method: .get, parameters: nil).responseJSON {
            (response) in
            
            // -- put your code below this line
            
            if (response.result.isSuccess) {
                print("awesome, i got a response from the website!")
                
                do {
                    let json = try JSON(data:response.data!)
                    var counter = 2
                    for i in 0...9{
                        let poke = json["results"]
                        print(poke[counter]["name"])
                        self.pokemons.append(poke[counter]["name"].stringValue)
                        self.pokeURL.append(poke[counter]["url"].stringValue)
                        counter = counter + 3
                    }
                    print(self.pokemons)
                    self.pickerView.reloadAllComponents()
                    /*for (index, object) in json["results"] {
                        let name = object["name"].stringValue
                        print(name)
                    }*/
                    
                }
                catch {
                    print ("Error while parsing JSON response")
                }
                
            }
            
        }
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pokemons.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pokemons[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        textView.text = ""
        defaultMoves = []
        upgradeableMoves = []
        // selected value in Uipickerview in Swift
        values = pokemons[row]
        
        let pokeImage: UIImage = UIImage(named: values)!
        imageView.image = pokeImage
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        print("values:----------\(values)");
        
        let URL = pokeURL[row]
        
        // ALAMOFIRE function: get the data from the website
        Alamofire.request(URL, method: .get, parameters: nil).responseJSON {
            (response) in
            
            // -- put your code below this line
            
            if (response.result.isSuccess) {
                print("awesome, i got a response from the website!")
                
                do {
                    let json = try JSON(data:response.data!)
                    let moves = json["moves"]
                        
                    for i in 0...3{
                        if(i == 0 || i == 1){
                            self.defaultMoves.append("\(moves[i]["move"]["name"])")
                        }else{
                            self.upgradeableMoves.append("\(moves[i]["move"]["name"])")
                        }
                    }
                    self.textView.text = "Moves available for this pokemon: \(self.defaultMoves[0]),"
                    self.textView.text += " \(self.defaultMoves[1]) \n"
                    self.textView.text += "Moves upgradeable for this pokemon: \(self.upgradeableMoves[0]),"
                    self.textView.text += " \(self.upgradeableMoves[1]) \n"
                }
                catch {
                    print ("Error while parsing JSON response")
                }
                    
            }
        }
        
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
        }
    }
    
    @IBAction func savePokemonPressed(_ sender: Any) {
        if(values != "Choose Pokemon" && values != ""){
            saveUserPokemon()
            performSegue(withIdentifier: "segueGameProfile", sender: nil)
        }else{
            showToast(controller: self, message: "Choose a pokemon", seconds: 1.5)
        }
    }
    
    public func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
        let length = Int64(range.upperBound - range.lowerBound + 1)
        let value = Int64(arc4random()) % length + Int64(range.lowerBound)
        return T(value)
    }
    
    func saveUserPokemon(){
        if(values != "Choose Pokemon"){
            guard let userEmail = Auth.auth().currentUser?.email else {
                return
            }
            let attack = randomNumber(inRange: 15...40)
            let defense = randomNumber(inRange: 10...12)
            userPokeData = ["email": String(userEmail),
                            "pokemeon": values,
                            "HP": 100,
                            "Money": 1000,
                            "Exp": 0,
                            "Level": 1,
                            "Wins": 0,
                            "attack": attack,
                            "defense": defense,
                            "default moves": defaultMoves,
                            "upgradeable moves": upgradeableMoves,
                            "upgradeable moves enabled": false
            ]
            db.collection("pokedata").document().setData([
                "email": String(userEmail),
                "pokemeon": values,
                "HP": 100,
                "Money": 1000,
                "Exp": 0,
                "Level": 1,
                "Wins": 0,
                "attack": attack,
                "defense": defense,
                "default moves": defaultMoves,
                "upgradeable moves": upgradeableMoves,
                "upgradeable moves enabled": false
                ])
        }else{
            showToast(controller: self, message: "Please choose a pokemon", seconds: 1.5)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let gamePage = segue.destination as! GameViewController
        gamePage.userData = userPokeData
    }
    

}
