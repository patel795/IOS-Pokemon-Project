//
//  NewPokemonViewController.swift
//  PokemonProject
//
//  Created by user147489 on 12/15/18.
//  Copyright © 2018 Rathin Chopra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ChameleonFramework
import Firebase
import WebKit

class NewPokemonViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var oldPokeImageView: UIImageView!
    @IBOutlet weak var newPokeImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pokemons:[String] = ["Choose Pokemon"]
    var pokeURL:[String] = ["Empty"]
    var values:String = ""
    var defaultMoves:[String] = []
    var upgradeableMoves:[String] = []
    var userPokeData = [String: Any]()
    var oldPokemonData = [String: Any]()
    
    
    // MARK: Initialize firestore variable
    // ------------------------------------
    var db:Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        db = Firestore.firestore()
        
        // OPTIONAL:  Required when dealing with dates that are stored in Firestore
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let oldPokeImage: UIImage = UIImage(named: oldPokemonData["pokemeon"] as! String)!
        oldPokeImageView.image = oldPokeImage
        oldPokeImageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        
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
                    
                    
                }
                catch {
                    print ("Error while parsing JSON response")
                }
                
            }
            
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if(values != "Choose Pokemon" && values != ""){
            saveToDataBase()
        }else{
            showToast(controller: self, message: "Choose a pokemon", seconds: 1.5)
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
            if(seconds == 3.0){
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func saveToDataBase(){
        guard let userEmail = Auth.auth().currentUser?.email else {
            return
        }
        self.db.collection("pokedata").getDocuments() {
            (querySnapshot, err) in
            
            // MARK: FB - Boilerplate code to get data from Firestore
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("---------------------------------------------")
                    let data = document.data()
                    let currentUserData = "\(data["email"]!)"
                    if(currentUserData == userEmail){
                        let id = document.documentID
                        self.db.collection("pokedata").document(id).setData([
                            "email": String(userEmail),
                            "pokemeon": self.values,
                            "HP": self.oldPokemonData["HP"]!,
                            "Money": self.oldPokemonData["Money"]!,
                            "Exp": self.oldPokemonData["Exp"]!,
                            "Wins": self.oldPokemonData["Wins"]!,
                            "Level": self.oldPokemonData["Level"]!,
                            "attack": self.oldPokemonData["attack"]!,
                            "defense": self.oldPokemonData["defense"]!,
                            "default moves": self.defaultMoves,
                            "upgradeable moves": self.upgradeableMoves,
                            "upgradeable moves enabled": self.oldPokemonData["upgradeable moves enabled"]!,
                            ])
                    }else{
                        print("Didnt save to database")
                    }
                    self.showToast(controller: self, message: "App will go back to login page to refresh data. Please Sign in again", seconds: 3.0)
                }
            }
        }
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
        newPokeImageView.image = pokeImage
        newPokeImageView.contentMode = UIView.ContentMode.scaleAspectFit
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
                    self.textView.text = "New Pokemon Moves \n"
                    self.textView.text += "Moves available for this pokemon: \(self.defaultMoves[0]),"
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
