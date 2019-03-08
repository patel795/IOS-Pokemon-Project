//
//  GameViewController.swift
//  PokemonProject
//
//  Created by user147489 on 12/8/18.
//  Copyright © 2018 Rathin Chopra. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class GameViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var userData = [String: Any]()
    var userPokeData = [String: Any]()
    var enemy1 = [String:Any]()
    var enemy2 = [String: Any]()
    var enemy3 = [String: Any]()
    var enemy4 = [String: Any]()
    var enemy5 = [String: Any]()
    var enemyTitle = ""
    var db:Firestore!
    var locationManager: CLLocationManager!
    var userLocation: CLLocation!
    var mapCounter = 0
    var didSelectEnemy = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        // OPTIONAL:  Required when dealing with dates that are stored in Firestore
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        textView.isUserInteractionEnabled = false
        textView.text = "HP: \(userData["HP"]!) \n"
        textView.text += "Attack: \(userData["attack"]!) \n"
        textView.text += "Defense: \(userData["defense"]!) \n"
        textView.text += "EXP: \(userData["Exp"]!) \n"
        textView.text += "Level: \(userData["Level"]!) \n"
        textView.text += "Money: $\(userData["Money"]!) \n"
        textView.text += "Wins: \(userData["Wins"]!) \n"
        mapView.delegate = self
        let pokeImage: UIImage = UIImage(named: userData["pokemeon"] as! String)!
        imageView.image = pokeImage
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
                        self.userData = data
                    }
                }
            }
        }
        print("--- \(userData["pokemeon"])")
        let pokeImage: UIImage = UIImage(named: userData["pokemeon"] as! String)!
        imageView.image = pokeImage
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        textView.text = "HP: \(userData["HP"]!) \n"
        textView.text += "Attack: \(userData["attack"]!) \n"
        textView.text += "Defense: \(userData["defense"]!) \n"
        textView.text += "EXP: \(userData["Exp"]!) \n"
        textView.text += "Level: \(userData["Level"]!) \n"
        textView.text += "Money: $\(userData["Money"]!) \n"
        textView.text += "Wins: \(userData["Wins"]!) \n"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
        userLocation = location
        print("user: \(userLocation!)")
        
        mapView.showsUserLocation = true
        self.mapView.setRegion(region, animated: true)
        
        if(mapCounter == 0){
            makeEnemies()
            addPins()
            mapCounter = 1
        }
    
        locationManager.stopUpdatingLocation()
    }
    
    public func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
        let length = Int64(range.upperBound - range.lowerBound + 1)
        let value = Int64(arc4random()) % length + Int64(range.lowerBound)
        return T(value)
    }
    
    func addPins(){
        //let c1 = randomNumber(inRange: -80...80)
        //let c2 = randomNumber(inRange: -170...170)
        let centerCoordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        
        // 2. Set the "zoom" level                      => span
        let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        
        // 3. Built the "view" -> (center & zoom)       => region
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        
        // 4. Update the map to show your "view"
        mapView.setRegion(region, animated: true)
        
        generateAnnoLoc()
        
    }
    
    func generateAnnoLoc() {
        
        var num = 0
        
        //First we declare While to repeat adding Annotation
        while num != 5 {
            num += 1
            
            //Add Annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate =  CLLocationCoordinate2DMake(userLocation.coordinate.latitude + Double(randomNumber(inRange: -8...8)), userLocation.coordinate.longitude + Double(randomNumber(inRange: -8...8)))
        
            annotation.title = "Pokemon Fight \(num)"
            mapView.addAnnotation(annotation)
            
        }
        makeFriends()
    }
    
    func makeFriends(){
        var num = 0
        
        while num != 3{
            num += 1
            
            //Add Annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate =  CLLocationCoordinate2DMake(userLocation.coordinate.latitude + Double(randomNumber(inRange: -8...8)), userLocation.coordinate.longitude + Double(randomNumber(inRange: -8...8)))
            
            annotation.title = "Friend"
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("didSelect")
        
        
        if let annotation = view.annotation {
            print("Your annotation title: \(String(describing: annotation.title!))")
            enemyTitle = annotation.title as! String
            if(enemyTitle == ("Pokemon Fight 1")){
                userInfoLabel.text = "Enemy's Info"
                textView.text = "HP: \(enemy1["HP"]!) \n"
                textView.text += "Attack: \(enemy1["attack"]!) \n"
                textView.text += "Defense: \(enemy1["defense"]!) \n"
                textView.text += "level: \(enemy1["level"]!) \n"
                let enemyImage: UIImage = UIImage(named: enemy1["pokemeon"] as! String)!
                imageView.image = enemyImage
            }else if(enemyTitle == "Pokemon Fight 2"){
                userInfoLabel.text = "Enemy's Info"
                textView.text = "HP: \(enemy2["HP"]!) \n"
                textView.text += "Attack: \(enemy2["attack"]!) \n"
                textView.text += "Defense: \(enemy2["defense"]!) \n"
                textView.text += "level: \(enemy2["level"]!) \n"
                let enemyImage: UIImage = UIImage(named: enemy2["pokemeon"] as! String)!
                imageView.image = enemyImage
            }else if(enemyTitle == "Pokemon Fight 3"){
                userInfoLabel.text = "Enemy's Info"
                textView.text = "HP: \(enemy3["HP"]!) \n"
                textView.text += "Attack: \(enemy3["attack"]!) \n"
                textView.text += "Defense: \(enemy3["defense"]!) \n"
                textView.text += "level: \(enemy3["level"]!) \n"
                let enemyImage: UIImage = UIImage(named: enemy3["pokemeon"] as! String)!
                imageView.image = enemyImage
            }else if(enemyTitle == "Pokemon Fight 4"){
                userInfoLabel.text = "Enemy's Info"
                textView.text = "HP: \(enemy4["HP"]!) \n"
                textView.text += "Attack: \(enemy4["attack"]!) \n"
                textView.text += "Defense: \(enemy4["defense"]!) \n"
                textView.text += "level: \(enemy4["level"]!) \n"
                let enemyImage: UIImage = UIImage(named: enemy4["pokemeon"] as! String)!
                imageView.image = enemyImage
            }else if(enemyTitle == "Pokemon Fight 5"){
                userInfoLabel.text = "Enemy's Info"
                textView.text = "HP: \(enemy5["HP"]!) \n"
                textView.text += "Attack: \(enemy5["attack"]!) \n"
                textView.text += "Defense: \(enemy5["defense"]!) \n"
                textView.text += "level: \(enemy5["level"]!) \n"
                let enemyImage: UIImage = UIImage(named: enemy5["pokemeon"] as! String)!
                imageView.image = enemyImage
            }else if(enemyTitle == "Friend"){
                userInfoLabel.text = "Friend"
                textView.text = "You can not fight your friend"
            }
            didSelectEnemy = true
        }
    }
    
    func makeEnemies(){
        for i in 1...5{
            let pokemons = ["arbok", "beedrill", "blastoise", "butterfree", "charizard", "nidorina", "pidgeot", "sandshrew", "spearow", "venusaur"]
            let rand = randomNumber(inRange: 0...9)
            let attack = randomNumber(inRange: 15...40)
            let defense = randomNumber(inRange: 10...12)
            let level = randomNumber(inRange: 3...25)
            userPokeData = [
                "pokemeon": pokemons[rand],
                "HP": 100,
                "attack": attack,
                "defense": defense,
                "level": level
            ]
            if(i == 1){
                enemy1 = userPokeData
            }else if(i == 2){
                enemy2 = userPokeData
            }else if(i == 3){
                enemy3 = userPokeData
            }else if(i == 4){
                enemy4 = userPokeData
            }else if(i == 5){
                enemy5 = userPokeData
            }
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        userInfoLabel.text = "User's Info"
        textView.text = "HP: \(userData["HP"]!) \n"
        textView.text += "Attack: \(userData["attack"]!) \n"
        textView.text += "Defense: \(userData["defense"]!) \n"
        textView.text += "EXP: \(userData["Exp"]!) \n"
        textView.text += "Level: \(userData["Level"]!) \n"
        textView.text += "Money: $\(userData["Money"]!) \n"
        textView.text += "Wins: \(userData["Wins"]!) \n"
        let pokeImage: UIImage = UIImage(named: userData["pokemeon"] as! String)!
        imageView.image = pokeImage
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        
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
    
    @IBAction func hospitalPressed(_ sender: Any) {
        if((userData["HP"] as! Int) < 100){
            userData["HP"] = 100
            userData["Money"] = (userData["Money"] as! Int) - 100
            self.showToast(controller: self, message: "Health Restored", seconds: 1.5)
            self.saveToDataBase()
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
            mapCounter = 0
            self.viewDidLoad()
        }
        else{
           showToast(controller: self, message: "Health is full", seconds: 1.5)
        }
    }
    
    @IBAction func newPokemonPressed(_ sender: Any) {
        performSegue(withIdentifier: "segueNewPokemon", sender: nil)
    }
    
    
    @IBAction func fightPressed(_ sender: Any) {
        performSegue(withIdentifier: "segueFight", sender: nil)
    }
    
    @IBAction func zoomInPressed(_ sender: Any) {
        let region = MKCoordinateRegion(center: self.mapView.region.center, span: MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta*0.7, longitudeDelta: mapView.region.span.longitudeDelta*0.7))
        mapView.setRegion(region, animated: true)
    }
    
    func getZoom() -> Double {
        
        var angleCamera = self.mapView.camera.heading
        if angleCamera > 270 {
            angleCamera = 360 - angleCamera
        } else if angleCamera > 90 {
            angleCamera = fabs(angleCamera - 180)
        }
        let angleRad = Double.pi * angleCamera / 180
        let width = Double(self.view.frame.size.width)
        let height = Double(self.view.frame.size.height)
        let heightOffset : Double = 20
        let spanStraight = width * self.mapView.region.span.longitudeDelta / (width * cos(angleRad) + (height - heightOffset) * sin(angleRad))
        return log2(360 * ((width / 256) / spanStraight)) + 1;
    }
    
    @IBAction func zoomOutPressed(_ sender: Any) {
        let zoom = getZoom() // to get the value of zoom of your map.
        if zoom > 3.5{ // **here i have used the condition that avoid the mapview to zoom less then 3.5 to avoid crash.**
            
            let region = MKCoordinateRegion(center: self.mapView.region.center, span: MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta/0.7, longitudeDelta: mapView.region.span.longitudeDelta/0.7))
            mapView.setRegion(region, animated: true)
        }
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueFight"){
            if(didSelectEnemy == true){
                let gameFight = segue.destination as! FightViewController
                gameFight.userData = self.userData
                if(enemyTitle == "Pokemon Fight 1"){
                    gameFight.enemyData = enemy1
                }else if(enemyTitle == "Pokemon Fight 2"){
                    gameFight.enemyData = enemy2
                }else if(enemyTitle == "Pokemon Fight 3"){
                    gameFight.enemyData = enemy3
                }else if(enemyTitle == "Pokemon Fight 4"){
                    gameFight.enemyData = enemy4
                }else if(enemyTitle == "Pokemon Fight 5"){
                    gameFight.enemyData = enemy5
                }else if(enemyTitle == "Friend"){
                    showToast(controller: self, message: "Select an enemy", seconds: 1.5)
                }
            }
            else{
                showToast(controller: self, message: "Select an enemy", seconds: 1.5)
            }
        }
        else if(segue.identifier == "segueNewPokemon"){
            let newPoke = segue.destination as! NewPokemonViewController
            newPoke.oldPokemonData = self.userData
        }
    }

}
