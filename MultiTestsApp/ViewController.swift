//
//  ViewController.swift
//  BalanceApp
//
//  Created by Alison Lui on 4/11/17.
//  Copyright © 2017 Alison Lui. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    //Instance Variables
    let PI = 3.14159265358979323846264
    var motionManager = CMMotionManager()
    
    var currentAccel = CMAcceleration()
    var currentOrien = CMAttitude()
    var currentRot = CMRotationRate()
    //var testBegun = false
    var testInProgess = false
    
    var updateTimer = Timer()
    
    var audioPlayer1 = AVAudioPlayer()
    
    //var steadyCount = 0   //was used to stop test by sensing when the person has stopped moving; this system has been changed to give the person a fixed amount of time for each segment of the test
    var testTimer = 0.0
    
    struct TotalMotion {
        var accel_x = Double()
        var accel_y = Double()
        var accel_z = Double()
        var accel_vertical = Double()
        var rot_x = Double()
        var rot_y = Double()
        var rot_z = Double()
        func dumpAccel() {
            print("(accel_x: \(accel_x) accel_y: \(accel_y) accel_z: \(accel_z))")
        }
    }
    
    struct testSegements { //test motion data divided by segment of test
        var sitting: [TotalMotion] = []             //seconds 0-22
        var sit_to_stand: [TotalMotion] = []        //seconds 22-36
        var stand_still: [TotalMotion] = []         //48-56
        var closed_eyes: [TotalMotion] = []         //1:03-1:11
        var feet_together: [TotalMotion] = []       //1:19-1:28
        var forward_reach: [TotalMotion] = []       //1:40-1:48
        var object_retrieval: [TotalMotion] = []    //2:02-2:15
        var look_behind: [TotalMotion] = []         //2:23-2:28
        var walk1: [TotalMotion] = []               //2:41-2:50
        var turn180: [TotalMotion] = []             //2:58-3:05
        var walk2: [TotalMotion] = []               //3:11-3:21
        var foot_lift: [TotalMotion] = []           //3:26-3:33
        var one_leg_stand: [TotalMotion] = []       //3:51-4:02
        var stand_to_sit: [TotalMotion] = []        //4:07-4:18
    }
    
    var testData = testSegements()
    
    override func viewDidLoad() {
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        //Set Motion Manager properties
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.gyroUpdateInterval = 0.1
        
        //Start Recording Data
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            
            if let mydata = accelerometerData {
                
                self.currentAccel = mydata.acceleration
                
            }
            if(NSError != nil) {
                print("\(String(describing: NSError))")
            }
        }
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { (deviceMotion: CMDeviceMotion?, NSError) -> Void in
            if let mydata = deviceMotion {
                
                self.currentOrien = mydata.attitude
                
            }
            if (NSError != nil){
                print("\(String(describing: NSError))")
            }
        })
        
        motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: { (gyroData: CMGyroData?, NSError) -> Void in
            if let mydata = gyroData {
                self.currentRot = mydata.rotationRate
            }
            if (NSError != nil){
                print("\(String(describing: NSError))")
            }
        })
        
        updateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.addDataPoint), userInfo: nil, repeats: true)
        
        let instructionsFile = "instruction_track.m4a"
        
        guard let path = Bundle.main.path(forResource: instructionsFile, ofType: nil) else {
            NSLog("Error: couldn't find file")
            return
        }
        let url = URL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            audioPlayer1 = sound
            sound.prepareToPlay()
        } catch {
            print("audioPlayer error \(error.localizedDescription)")
        }
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func beginTest(_ sender: Any) {
        if(!testInProgess){
            audioPlayer1.play()
            //testBegun = true
            testInProgess = true
            testTimer = 0
        }
    }
    
    /* Doesn't work; would be great if it did
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            print("SAY SOMETHING IM GIVING UP ON YOU")
    }
    */
    
    func addDataPoint(){
        if(testInProgess){
            testTimer += 0.1
            var value = TotalMotion();
            value.accel_vertical = isolateTrueZacc(acceleration: self.currentAccel, orientation: self.currentOrien)
            value.accel_x = self.currentAccel.x;
            value.accel_y = self.currentAccel.y;
            value.accel_z = self.currentAccel.z;
            value.rot_x = self.currentRot.x;
            value.rot_y = self.currentRot.y;
            value.rot_z = self.currentRot.z;
            if(testTimer<22){
                self.testData.sitting.append(value)
            }else if(testTimer<36){
                self.testData.sit_to_stand.append(value)
            }else if(testTimer>48 && testTimer<56){
                self.testData.stand_still.append(value)
            }else if(testTimer>63 && testTimer<71){
                self.testData.closed_eyes.append(value)
            }else if(testTimer>79 && testTimer<88){
                self.testData.feet_together.append(value)
            }else if(testTimer>100 && testTimer<108){
                self.testData.forward_reach.append(value)
            }else if(testTimer>122 && testTimer<135){
                self.testData.object_retrieval.append(value)
            }else if(testTimer>143 && testTimer<148){
                self.testData.look_behind.append(value)
            }else if(testTimer>161 && testTimer<170){
                self.testData.walk1.append(value)
            }else if(testTimer>178 && testTimer<185){
                self.testData.turn180.append(value)
            }else if(testTimer>191 && testTimer<201){
                self.testData.walk2.append(value)
            }else if(testTimer>206 && testTimer<213){
                self.testData.foot_lift.append(value)
            }else if(testTimer>231 && testTimer<242){
                self.testData.one_leg_stand.append(value)
            }else if(testTimer>247 && testTimer<258){
                self.testData.stand_to_sit.append(value)
            }else if(testTimer>=258){
                stopTest()
            }
            /*
            if isSteadyValue(value: value){
                steadyCount += 1
            }else{
                steadyCount = 0
            }
            */
            //value.dumpAccel()
        /*
            if steadyCount>=30{
                stopTest()
            }
        }else if(testBegun){
            preTestWaitCount += 1
            if(preTestWaitCount>45){
                testInProgess = true
                testBegun = false
                preTestWaitCount = 0
            }
        */
        }
    }
    
    /*
    func isSteadyValue(value: TotalAccel) -> Bool {
        if value.x>0.97 && value.x<1.1 && value.y > -0.1 && value.y<0.2 && value.z > -0.3 && value.z<0.2{
            return true
        }
        return false
    }
    */
    
    func stopTest(){
        testInProgess = false
        print("Time taken: \(testTimer) seconds")
        print(testData)
    }

    func isolateTrueZacc(acceleration: CMAcceleration, orientation: CMAttitude) -> Double {
        let truez = acceleration.z * cos(orientation.pitch) * cos(orientation.roll) + acceleration.y * cos(self.PI/2.0 - orientation.pitch) - acceleration.x * cos(self.PI/2.0 - orientation.roll)
        return truez
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeLeft
    }
    private func shouldAutorotate() -> Bool {
        return true
    }


}

