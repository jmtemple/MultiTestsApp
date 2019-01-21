
//
//  MotorGameViewController.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 6/27/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MotorGameViewController: UIViewController {
    
    let manager = CMMotionManager()
    var accelData = [CMAcceleration]()
    var circleData = [CMAcceleration]()
    var squareData = [CMAcceleration]()
    
    var onCircle = false
    var onSquare = false
    var firstTap = false
    var tapForSquare = false
    var avoidTaps = false
    var countDownCount: Int = 4
    
    //initials from consent vc
    var initialsText = ""
    
    //file writer
    var fileWriter: FileWriter!
    
    // persistence
    let defaults = UserDefaults.standard
    var motorResults = [MotorResult]()
    
    /*
    var vix: Double = 0
    var vfx: Double = 0
    var viy: Double = 0
    var vfy: Double = 0
    var lastPoint: CGPoint?
    var currPoint: CGPoint?
    var currentAccel = CMAcceleration()
    */
    
    let shapeLayer = CAShapeLayer()
    
    var countdown = Timer()
    
    @IBOutlet weak var finishLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var nextGameButton: UIButton!
    
    override func viewDidLoad() {
        self.drawCircle()
        self.finishLabel.isHidden = true
        self.nextGameButton.isHidden = true
        //self.lastPoint = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2 - 170)
        //self.currPoint = lastPoint
       
        /*
        let alert = UIAlertController(title: "Instructions", message: "Hold the iPad directly in front of you with both hands and trace the following shapes in the air", preferredStyle: UIAlertControllerStyle.alert)
        //let alert = UIAlertController(title: "This time, please repeat the following phrase as you trace the shapes in the air: We saw several wild animals", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        */
        let fileName = "\(initialsText)"
        
        fileWriter = FileWriter.sharedInstance
        fileWriter.setFileName(name: fileName)
        
        
        fileWriter.write(text: "\(Utils.timeOnly()), Motor Trace Shape Game Begins")
      
 
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to:
        OperationQueue.current!) { (accelerometerData:
            CMAccelerometerData?, NSError) -> Void in
            
            if let data = accelerometerData {
                //self.currentAccel = data.acceleration
                self.accelData.append(data.acceleration)
                if(self.onCircle){
                    self.circleData.append(data.acceleration)
                }
                if(self.onSquare){
                    self.squareData.append(data.acceleration)
                }
                //self.updatePoint()
            }
            if(NSError != nil) {
                print("\(String(describing: NSError))")
            }
        }
    }
    
    func countDown(){
        self.countDownCount = self.countDownCount - 1
        //if the countdown is 0 - the game is over
        if(self.countDownCount == 0){
            self.avoidTaps = false
            self.countDownLabel.text = "Go"
            if(self.tapForSquare){
                self.onSquare = true
                self.tapForSquare = false
                fileWriter.write(text: "\(Utils.timeOnly()), square_begins")
            } else {
                self.onCircle = true
                fileWriter.write(text: "\(Utils.timeOnly()), circle_begins")
            }
        } else if(self.countDownCount < 0){
            self.countDownLabel.isHidden = true
            self.countdown.invalidate()
            //self.endGame()
            return
        } else {
            self.countDownLabel.text = String(format: "%d", self.countDownCount)
        }
    }
    
    func drawCircle() {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: view.bounds.width/2, y: view.bounds.height/2), radius: 170, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        self.shapeLayer.path = circlePath.cgPath
        self.shapeLayer.fillColor = UIColor.clear.cgColor
        self.shapeLayer.strokeColor = UIColor.black.cgColor
        self.shapeLayer.lineWidth = 3.0
        view.layer.addSublayer(self.shapeLayer)
        
    }
    
    func drawSquare(){
        self.shapeLayer.removeFromSuperlayer()
        self.countDownLabel.text = "Tap when ready"
        let squarePath = UIBezierPath(rect: CGRect(x: view.bounds.width/2 - 170, y: view.bounds.height/2 - 170, width: 170*2, height: 170*2))
       
        self.shapeLayer.path = squarePath.cgPath
        self.shapeLayer.fillColor = UIColor.clear.cgColor
        self.shapeLayer.strokeColor = UIColor.black.cgColor
        self.shapeLayer.lineWidth = 3.0
        view.layer.addSublayer(self.shapeLayer)
    }
    
    func saveData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity: MotorResult =  NSEntityDescription.insertNewObject(forEntityName: "MotorResult", into: managedContext) as! MotorResult
        
        entity.speech = false
        
        fileWriter.write(text: "accel_whole_time_starts")
        for acceleration in self.accelData {
            let newAccel: DeviceAcceleration =  NSEntityDescription.insertNewObject(forEntityName: "DeviceAcceleration", into: managedContext) as! DeviceAcceleration
            newAccel.x = acceleration.x
            newAccel.y = acceleration.y
            newAccel.z = acceleration.z
            newAccel.motorResult = entity
            fileWriter.write(text: "X: \(newAccel.x), Y: \(newAccel.y), Z: \(newAccel.z)")
        }
        fileWriter.write(text: "accel_whole_time_ends")
        fileWriter.write(text: "accel_circle_time_starts")
        for acceleration in self.circleData {
            let newAccel: DeviceAcceleration =  NSEntityDescription.insertNewObject(forEntityName: "DeviceAcceleration", into: managedContext) as! DeviceAcceleration
            newAccel.x = acceleration.x
            newAccel.y = acceleration.y
            newAccel.z = acceleration.z
            newAccel.circleAccel = entity
            fileWriter.write(text: "X: \(newAccel.x), Y: \(newAccel.y), Z: \(newAccel.z)")
        }
        fileWriter.write(text: "accel_circle_time_ends")
        fileWriter.write(text: "accel_square_time_starts")
        for acceleration in self.squareData {
            let newAccel: DeviceAcceleration =  NSEntityDescription.insertNewObject(forEntityName: "DeviceAcceleration", into: managedContext) as! DeviceAcceleration
            newAccel.x = acceleration.x
            newAccel.y = acceleration.y
            newAccel.z = acceleration.z
            newAccel.squareAccel = entity
            fileWriter.write(text: "X: \(newAccel.x), Y: \(newAccel.y), Z: \(newAccel.z)")
        }
        fileWriter.write(text: "accel_square_time_ends")
        
        
        do {
            try managedContext.save()
            motorResults.append(entity)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(self.avoidTaps){
            return
        }
        
        if(!self.firstTap){
            self.countdown = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
            self.firstTap = true
            self.finishLabel.isHidden = false
            self.avoidTaps = true
            fileWriter.write(text: "\(Utils.timeOnly()), first_tap")
        } else if(self.onCircle){
            self.onCircle = false
            self.finishLabel.isHidden = true
            self.countDownLabel.text = "Good"
            self.countDownLabel.isHidden = false
            self.tapForSquare = true
            self.countdown = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(drawSquare), userInfo: nil, repeats: false)
            fileWriter.write(text: "\(Utils.timeOnly()), circle_ends")
        } else if(self.tapForSquare){
            self.countDownCount = 4
            self.countdown = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
            self.finishLabel.isHidden = false
            self.avoidTaps = true
            fileWriter.write(text: "\(Utils.timeOnly()), tap_for_square")
        } else if(self.onSquare){
            self.onSquare = false
            self.finishLabel.isHidden = true
            self.countDownLabel.text = "Good"
            self.countDownLabel.isHidden = false
            self.nextGameButton.isHidden = false
            self.saveData()
            fileWriter.write(text: "\(Utils.timeOnly()), all_ends")
        }
    }
    
    
    @IBAction func submitAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
        fileWriter.write(text: "\(Utils.timeOnly()), Motor Trace Shape Game End")
        
        
    }
    
}
