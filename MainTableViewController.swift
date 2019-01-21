//
//  MainTableViewController.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 10/3/16.
//  Copyright © 2016 NDMobileCompLab. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    var device: String = "iPhone" // iPhone is the default
    
    var firstName = ""
    var lastName = ""
    var birthYear = ""
    var diagnosis = ""
    
    var initialsText = ""
    var gameType = ""
    var gameIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialsText = "\(firstName)_\(lastName)_\(birthYear)_\(diagnosis)"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Tabvarview data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 19
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let mainCell = cell as? MainTableViewCell {
            
            // setting font sizes
            if (device == "iPhone") {
                mainCell.nameLabel.font = UIFont(name: "Arial", size: 18.0)
                mainCell.descriptionLabel.font = UIFont(name: "Arial", size: 12.0)
            } else {
                mainCell.nameLabel.font = UIFont(name: "Arial", size: 36.0)
                mainCell.descriptionLabel.font = UIFont(name: "Arial", size: 24.0)
            }
            
            // setting image
            mainCell.cellImage.image = UIImage(named: "placeholder")
            
            if (indexPath.row == 0) {
                mainCell.cellImage.image = #imageLiteral(resourceName: "TracewoAudio")
                mainCell.nameLabel?.text = "Trace Shapes"
                mainCell.descriptionLabel.text = "Trace the shapes shown on the screen."
            } else if (indexPath.row == 1) {
                mainCell.cellImage.image = #imageLiteral(resourceName: "TracewAudio")
                mainCell.nameLabel?.text = "Trace Shapes with Speech"
                mainCell.descriptionLabel.text = "While listing the months of the year, trace the shapes shown on the screen."
            } else if (indexPath.row == 2){
                mainCell.nameLabel?.text = "Motor Function"
                mainCell.descriptionLabel.text = "Motion the shapes in the air with the device."
                mainCell.cellImage.image = #imageLiteral(resourceName: "MotorFunctionW:oAudio")
            } else if (indexPath.row == 3){
                mainCell.nameLabel?.text = "Motor Function with Speech"
                mainCell.descriptionLabel.text = "While listing the months of the year, motion the shapes in the air with the device."
                mainCell.cellImage.image = #imageLiteral(resourceName: "MotorFuntionAudio")
            } else if (indexPath.row == 4) {
                mainCell.cellImage.image = #imageLiteral(resourceName: "TracewBrain")
                mainCell.nameLabel?.text = "Trace Shapes Cognitive Load"
                mainCell.descriptionLabel.text = "While listing the months of the year in reverse, trace the shapes shown on the screen."
            } else if (indexPath.row == 5){
                mainCell.nameLabel?.text = "Motor Function Cognitive Load"
                mainCell.descriptionLabel.text = "While listing the months of the year backwards, motion the shapes in the air with the device."
                mainCell.cellImage.image = #imageLiteral(resourceName: "MotorFuntionBrain")
            }else if (indexPath.row == 6){
                mainCell.nameLabel?.text = "Memory Game"
                mainCell.descriptionLabel.text = "Flip cards to find all matching pairs of images."
                mainCell.cellImage.image = #imageLiteral(resourceName: "memoryGame2")
            } else if (indexPath.row == 7){
                mainCell.nameLabel?.text = "Memory Game"
                mainCell.descriptionLabel.text = "Flip cards to find all matching pairs of images."
                mainCell.cellImage.image = #imageLiteral(resourceName: "memoryGame")
            } else if (indexPath.row == 8) {
                mainCell.nameLabel?.text = "Falling Ball Activity"
                mainCell.descriptionLabel.text = "Stop the falling ball on the target."
                mainCell.cellImage.image = #imageLiteral(resourceName: "fallingball")
            } else if (indexPath.row == 9) {
                mainCell.nameLabel?.text = "Target Test"
                mainCell.descriptionLabel.text = "Tap on the targets shown."
                mainCell.cellImage.image = #imageLiteral(resourceName: "Target.png")
            } else if (indexPath.row == 10) {
                mainCell.nameLabel?.text = "Connect the Dots"
                mainCell.descriptionLabel.text = "Connect the dots in increasing numerical order from 1-10"
                mainCell.cellImage.image = #imageLiteral(resourceName: "bground")
            } else if (indexPath.row == 11) {
                mainCell.nameLabel?.text = "Visuospatial Test"
                mainCell.descriptionLabel.text = "Connect the shapes in increasing numerical order from 1-10."
                mainCell.cellImage.image = #imageLiteral(resourceName: "bground1")
            } else if (indexPath.row == 12) {
                mainCell.nameLabel?.text = "Color Test"
                mainCell.descriptionLabel.text = "Say the color of each word."
                mainCell.cellImage.image = #imageLiteral(resourceName: "ColorThumb")
            } else if (indexPath.row == 13) {
                mainCell.nameLabel?.text = "Picture Test"
                mainCell.descriptionLabel.text = "Say the word that best corresponds to the picture shown."
                mainCell.cellImage.image = #imageLiteral(resourceName: "Apple")
            } else if (indexPath.row == 14) {
                mainCell.nameLabel?.text = "Balance Test"
                mainCell.descriptionLabel.text = "Place the device in the harness and perform a series of balance tests."
                mainCell.cellImage.image = #imageLiteral(resourceName: "pose")
                mainCell.isHidden = true
            } else if (indexPath.row == 15) {
                mainCell.nameLabel?.text = "Connect the Dots"
                mainCell.descriptionLabel.text = "Connect the dots to complete the drawing."
                mainCell.cellImage.image = #imageLiteral(resourceName: "flowerdraw")
                mainCell.isHidden = true
            } else if (indexPath.row == 16) {
                mainCell.nameLabel?.text = "Narration"
                mainCell.descriptionLabel.text = "Read the sentence shown aloud."
                mainCell.cellImage.image = #imageLiteral(resourceName: "speaking")
            } else if (indexPath.row == 17) {
                mainCell.nameLabel?.text = "Narration Writer"
                mainCell.descriptionLabel.text = "Narrate the sentence shown while writing it in the space provided."
                mainCell.cellImage.image = #imageLiteral(resourceName: "feedback")
            } else if (indexPath.row == 18) { // setting title and description
                mainCell.cellImage.image = #imageLiteral(resourceName: "signature")
                mainCell.nameLabel?.text = "Signature Confirmation"
                mainCell.descriptionLabel.text = "Sign your name on the line to confirm that the completed data is yours and done to the best of your knowledge."
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            self.performSegue(withIdentifier: "gameSegue1", sender: self)
        } else if (indexPath.row == 1){
            self.performSegue(withIdentifier: "gameSegue2", sender: self)
        } else if (indexPath.row == 2){
            self.performSegue(withIdentifier: "gameSegue4", sender: self)
        } else if (indexPath.row == 3) {
            self.performSegue(withIdentifier: "gameSegue5", sender: self)
        } else if (indexPath.row == 4) {
            self.performSegue(withIdentifier: "gameSegue3", sender: self)
        } else if (indexPath.row == 5) {
            self.performSegue(withIdentifier: "gameSegue6", sender: self)
        } else if (indexPath.row == 6) {
            self.gameType = "colorshape"
            self.performSegue(withIdentifier: "gameSegue7", sender: self)
        } else if (indexPath.row == 7) {
            self.gameType = "card"
            self.performSegue(withIdentifier: "gameSegue7", sender: self)
        } else if (indexPath.row == 8) {
            self.performSegue(withIdentifier: "gameSegue9", sender: self)
        } else if (indexPath.row == 9) {
            self.performSegue(withIdentifier: "gameSegue14", sender: self)
        } else if (indexPath.row == 10) {
            self.gameIndex = 0
            self.performSegue(withIdentifier: "gameSegue10", sender: self)
        } else if (indexPath.row == 11) {
            self.gameIndex = 1
            self.performSegue(withIdentifier: "gameSegue10", sender: self)
        } else if (indexPath.row == 12) {
            self.performSegue(withIdentifier: "gameSegue11", sender: self)
        } else if (indexPath.row == 13) {
            self.performSegue(withIdentifier: "gameSeguePicture", sender: self)
        } else if (indexPath.row == 14) {
            self.performSegue(withIdentifier: "gameSegue13", sender: self)
		} else if (indexPath.row == 15) {
            self.performSegue(withIdentifier: "gameSegue8", sender: self)
        } else if (indexPath.row == 16){
            self.performSegue(withIdentifier: "gameSegueSentence", sender: self)
        } else if (indexPath.row == 17){
            self.performSegue(withIdentifier: "gameSegueNarration", sender: self)
        } else if (indexPath.row == 18) {
            self.performSegue(withIdentifier: "gameSegue0", sender: self)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // function determines if app is running on an iPhone or iPad
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            switch traitCollection.horizontalSizeClass {
            case .compact: device = "iPhone"
            case .regular: device = "iPad"
            default: device = "iPhone"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (device == "iPhone") {
            return 100
        } else if(indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 14 || indexPath.row==15){
            return 0
        }else {
            return 175
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "gameSegue0") {
            if let dest = segue.destination as? SignatureViewController {
                dest.initialsText = self.initialsText
            }
            
        } else if (segue.identifier == "gameSegue1") {
            if let dest = segue.destination as? TraceShapeViewController {
                // The data passed here is whether or not the app is running 
                // on an iPhone or iPad (for formatting purposes)
                dest.device = self.device
                dest.initialsText = self.initialsText
            }
        } else if (segue.identifier == "gameSegue8") {
            if let dest = segue.destination as? ConnectDotsViewController {
                dest.device = self.device
            }
        } else if (segue.identifier == "gameSegueSentence"){
            if let dest = segue.destination as? SentenceViewController {
                dest.initialsText = self.initialsText
            }

        } else if (segue.identifier == "gameSegueNarration"){
            if let dest = segue.destination as? NarrationWriterViewController {
                dest.initialsText = self.initialsText
            }
            
        } else if (segue.identifier == "gameSeguePicture"){
            if let dest = segue.destination as? PictureGameViewController {
                dest.initialsText = self.initialsText
            }
            
        } else if (segue.identifier == "gameSegue11"){
                if let dest = segue.destination as? ColorGameViewController {
                    dest.initialsText = self.initialsText
                }
            
        } else if (segue.identifier == "gameSegue2"){
            if let dest = segue.destination as? TraceShapeSpeechViewController {
                dest.initialsText = self.initialsText
            }
            
        } else if (segue.identifier == "gameSegue3"){
            if let dest = segue.destination as? TraceShapeCognitiveViewController {
                dest.initialsText = self.initialsText
            }
            
        } else if (segue.identifier == "gameSegue4"){
            if let dest = segue.destination as? MotorGameViewController {
                dest.initialsText = self.initialsText
            }
            
        } else if (segue.identifier == "gameSegue5"){
            if let dest = segue.destination as? MotorSpeechGameViewController {
                dest.initialsText = self.initialsText
            }
            
        } else if (segue.identifier == "gameSegue6"){
            if let dest = segue.destination as? MotorCognitiveGameViewController {
                dest.initialsText = self.initialsText
            }
            
        } else if (segue.identifier == "gameSegue7"){
            if let dest = segue.destination as? GameController {
                dest.initialsText = self.initialsText
                dest.gameType = self.gameType
            }
            
        } else if (segue.identifier == "gameSegue9"){
            if let dest = segue.destination as? GameViewController {
                dest.initialsText = self.initialsText
            }
            
        } else if (segue.identifier == "gameSegue14"){
            if let dest = segue.destination as? TargetGameViewController {
                dest.initialsText = self.initialsText
            }
            
        } else if (segue.identifier == "gameSegue10"){
            if let dest = segue.destination as? VisuospatialViewController {
                dest.initialsText = self.initialsText
                dest.gameIndex = self.gameIndex
            }
            
        }
    }
}
