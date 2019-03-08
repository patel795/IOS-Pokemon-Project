//
//  FightViewController.swift
//  PokemonProject
//
//  Created by user147489 on 12/8/18.
//  Copyright © 2018 Rathin Chopra. All rights reserved.
//

import UIKit
import Firebase

class FightViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var enemyProgressView: UIProgressView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var enemyImageView: UIImageView!
    @IBOutlet weak var attackImageView: UIImageView!
    @IBOutlet weak var attackButton1: UIButton!
    @IBOutlet weak var attackButton2: UIButton!
    @IBOutlet weak var attackButton3: UIButton!
    @IBOutlet weak var attackButton4: UIButton!
    
    var enemyData = [String: Any]()
    var userData = [String: Any]()
    var currentTime:Float = 0
    var db:Firestore!
    var userWinCounter = 0
    var enemyWinCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isUserInteractionEnabled = false
        textView.text = "\(userData)"
        
        db = Firestore.firestore()
        
        // OPTIONAL:  Required when dealing with dates that are stored in Firestore
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let moves:[Any] = userData["default moves"] as! [Any]
        let upMoves:[Any] = userData["upgradeable moves"] as! [Any]
        
        attackButton1.setTitle(moves[0] as? String, for: .normal)
        attackButton2.setTitle(moves[1] as? String, for: .normal)
        attackButton3.setTitle(upMoves[0] as? String, for: .normal)
        attackButton4.setTitle(upMoves[1] as? String, for: .normal)
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        let upMovesEnabler = userData["upgradeable moves enabled"] as! Bool
        if(upMovesEnabler){
            attackButton3.isEnabled = true
            attackButton4.isEnabled = true
        }else{
            attackButton3.isEnabled = false
            attackButton4.isEnabled = false
        }
        
        let imageName = userData["pokemeon"] as! String
        let pokeImage: UIImage = UIImage(named: "\(imageName)-back")!
        userImageView.image = pokeImage
        userImageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        let enemyPokeImage: UIImage = UIImage(named: enemyData["pokemeon"] as! String)!
        enemyImageView.image = enemyPokeImage
        enemyImageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        progressView.setProgress((userData["HP"]!  as! NSNumber).floatValue/100, animated: true)
        
    }
    
    @objc func updateProgressBar(){
        
        
        
        if(progressView.progress != 0){
            perform(#selector(updateProgressBar), with: nil, afterDelay: 1.0)
        }
        else{
            progressView.progress = 0
        }
        
    }

    
    @IBAction func firstAttackPressed(_ sender: Any) {
        let damage = (userData["attack"] as! Int) - (enemyData["defense"] as! Int)
        enemyData["HP"] = (enemyData["HP"] as! Int) - damage
        enemyProgressView.progress = enemyProgressView.progress - (Float(damage)/100)
        print(enemyData["HP"]!)
        
        let attackImage: UIImage = UIImage(named: "user-attack")!
        attackImageView.image = attackImage
        attackImageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.attackImageView.isHidden = false
        
        UIView.animate(withDuration: 1.0, animations: {
            self.attackImageView.frame.origin.y -= 160
            
        })
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            if((self.enemyData["HP"] as! Int) <= 0){
                self.attackButton1.isEnabled = false
                self.attackButton2.isEnabled = false
                self.attackButton3.isEnabled = false
                self.attackButton4.isEnabled = false
                self.attackImageView.isHidden = true
                if(self.userWinCounter == 0){
                    self.giveEXP()
                    self.userWinCounter = 1
                }
                self.showToast(controller: self, message: "you won the game", seconds: 1.0)
                print("user won")
                return
            }else{
                self.attackImageView.isHidden = true
                self.enemyAttack()
            }
        }
    }
    
    @IBAction func secondAttackPressed(_ sender: Any) {
        let damage = (userData["attack"] as! Int) - (enemyData["defense"] as! Int)
        enemyData["HP"] = (enemyData["HP"] as! Int) - damage
        enemyProgressView.progress = enemyProgressView.progress - (Float(damage)/100)
        print(enemyData["HP"]!)
        
        let attackImage: UIImage = UIImage(named: "user-attack")!
        attackImageView.image = attackImage
        attackImageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.attackImageView.isHidden = false
        
        UIView.animate(withDuration: 1.0, animations: {
            self.attackImageView.frame.origin.y -= 160
            
        })
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            if((self.enemyData["HP"] as! Int) <= 0){
                self.attackButton1.isEnabled = false
                self.attackButton2.isEnabled = false
                self.attackButton3.isEnabled = false
                self.attackButton4.isEnabled = false
                self.attackImageView.isHidden = true
                if(self.userWinCounter == 0){
                    self.giveEXP()
                    self.userWinCounter = 1
                }
                self.showToast(controller: self, message: "you won the game", seconds: 1.0)
                print("user won")
                return
            }else{
                self.attackImageView.isHidden = true
                self.enemyAttack()
            }
        }
    }
    
    @IBAction func thirdAttackPressed(_ sender: Any) {
        let damage = (userData["attack"] as! Int) - (enemyData["defense"] as! Int) + randomNumber(inRange: 1...10)
        enemyData["HP"] = (enemyData["HP"] as! Int) - damage
        enemyProgressView.progress = enemyProgressView.progress - (Float(damage)/100)
        print(enemyData["HP"]!)
        
        let attackImage: UIImage = UIImage(named: "user-attack")!
        attackImageView.image = attackImage
        attackImageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.attackImageView.isHidden = false
        
        UIView.animate(withDuration: 1.0, animations: {
            self.attackImageView.frame.origin.y -= 160
            
        })
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            if((self.enemyData["HP"] as! Int) <= 0){
                self.attackButton1.isEnabled = false
                self.attackButton2.isEnabled = false
                self.attackButton3.isEnabled = false
                self.attackButton4.isEnabled = false
                self.attackImageView.isHidden = true
                if(self.userWinCounter == 0){
                    self.giveEXP()
                    self.userWinCounter = 1
                }
                self.showToast(controller: self, message: "you won the game", seconds: 1.0)
                print("user won")
                return
            }else{
                self.attackImageView.isHidden = true
                self.enemyAttack()
            }
        }
    }
    
    @IBAction func fourthAttackPressed(_ sender: Any) {
        let damage = (userData["attack"] as! Int) - (enemyData["defense"] as! Int) + randomNumber(inRange: 1...10)
        enemyData["HP"] = (enemyData["HP"] as! Int) - damage
        enemyProgressView.progress = enemyProgressView.progress - (Float(damage)/100)
        print(enemyData["HP"]!)
        
        let attackImage: UIImage = UIImage(named: "user-attack")!
        attackImageView.image = attackImage
        attackImageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.attackImageView.isHidden = false
        
        UIView.animate(withDuration: 1.0, animations: {
            self.attackImageView.frame.origin.y -= 160
            
        })
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            if((self.enemyData["HP"] as! Int) <= 0){
                self.attackButton1.isEnabled = false
                self.attackButton2.isEnabled = false
                self.attackButton3.isEnabled = false
                self.attackButton4.isEnabled = false
                self.attackImageView.isHidden = true
                if(self.userWinCounter == 0){
                    self.giveEXP()
                    self.userWinCounter = 1
                }
                self.showToast(controller: self, message: "you won the game", seconds: 1.0)
                print("user won")
                return
            }else{
                self.attackImageView.isHidden = true
                self.enemyAttack()
            }
        }
    }
    
    @IBAction func runPressed(_ sender: Any) {
        let run = randomNumber(inRange: 0...1)
        if(run == 1){
            self.navigationController?.popViewController(animated: true)
        }
        else{
            UIView.animate(withDuration: 0, animations: {
                self.attackImageView.frame.origin.y -= 160
                
            })
            enemyAttack()
        }
    }
    
    public func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
        let length = Int64(range.upperBound - range.lowerBound + 1)
        let value = Int64(arc4random()) % length + Int64(range.lowerBound)
        return T(value)
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
    
    func enemyAttack(){
        let damage = (enemyData["attack"] as! Int) - (userData["defense"] as! Int)
        userData["HP"] = (userData["HP"] as! Int) - damage
        
        let attackImage: UIImage = UIImage(named: "enemy-attack")!
        attackImageView.image = attackImage
        attackImageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.attackImageView.isHidden = false
        
        UIView.animate(withDuration: 1.0, animations: {
            self.attackImageView.frame.origin.y += 160
            
        })
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            if((self.userData["HP"] as! Int) <= 0){
                self.attackButton1.isEnabled = false
                self.attackButton2.isEnabled = false
                self.attackButton3.isEnabled = false
                self.attackButton4.isEnabled = false
                self.attackImageView.isHidden = true
                self.progressView.progress = self.progressView.progress - (Float(damage)/100)
                self.showToast(controller: self, message: "Enemy Won the Game", seconds: 1.0)
                if(self.enemyWinCounter == 0){
                    self.userData["HP"] = 0
                    let moneyDeduct = 4 * (self.enemyData["level"] as! Int)
                    self.userData["Money"] = (self.userData["Money"] as! Int) - moneyDeduct
                    self.enemyWinCounter = 1
                    self.saveToDataBase()
                }
                print("enemy won")
                return
            }else{
                self.attackImageView.isHidden = true
                self.progressView.progress = self.progressView.progress - (Float(damage)/100)
            }
        }
       
        print("user hp = \(userData["HP"]!)")
    }
    
    func giveEXP(){
        if((enemyData["level"] as! Int) <= 5){
            let exp = randomNumber(inRange: 15...30)
            let money = randomNumber(inRange: 40...70)
            userData["Exp"] = (userData["Exp"] as! Int) + exp
            userData["Money"] = (userData["Money"] as! Int) + money
            userData["Level"] = round(0.1 * sqrt(Double(userData["Exp"] as! Int)))
        }
        else if(((enemyData["level"] as! Int) >= 5) && ((enemyData["level"] as! Int) <= 15)){
            let exp = randomNumber(inRange: 30...60)
            let money = randomNumber(inRange: 70...100)
            userData["Exp"] = (userData["Exp"] as! Int) + exp
            userData["Money"] = (userData["Money"] as! Int) + money
            userData["Level"] = round(0.1 * sqrt(Double(userData["Exp"] as! Int)))
        }
        else if(((enemyData["level"] as! Int) >= 15) && ((enemyData["level"] as! Int) <= 25)){
            let exp = randomNumber(inRange: 60...120)
            let money = randomNumber(inRange: 100...200)
            userData["Exp"] = (userData["Exp"] as! Int) + exp
            userData["Money"] = (userData["Money"] as! Int) + money
            userData["Level"] = round(0.1 * sqrt(Double(userData["Exp"] as! Int)))
        }
        
        if((userData["Level"] as! Double) >= 4){
            userData["upgradeable moves enabled"] = true
        }
        userData["Wins"] = (userData["Wins"] as! Int) + 1
        saveToDataBase()
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
                            "pokemeon": self.userData["pokemeon"]!,
                            "HP": self.userData["HP"]!,
                            "Money": self.userData["Money"]!,
                            "Exp": self.userData["Exp"]!,
                            "Wins": self.userData["Wins"]!,
                            "Level": self.userData["Level"]!,
                            "attack": self.userData["attack"]!,
                            "defense": self.userData["defense"]!,
                            "default moves": self.userData["default moves"]!,
                            "upgradeable moves": self.userData["upgradeable moves"]!,
                            "upgradeable moves enabled": self.userData["upgradeable moves enabled"]!,
                            ])
                    }else{
                        print("Didnt save to database")
                    }
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
