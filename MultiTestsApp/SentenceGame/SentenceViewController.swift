
//
//  SentenceViewController.swift
//
//
//  Created by John Templeton on 7/25/18.
//  Copyright © 2018 John Templeton. All rights reserved.
//

import Foundation
import UIKit
import Speech
import GameKit
import CoreData
import CoreMotion

class SentenceViewController: UIViewController, SFSpeechRecognizerDelegate{
    
    // persistence
    let defaults = UserDefaults.standard
    var signatureResults = [SignatureResult]()
    
    
    //initials from consent vc
    var initialsText = ""
    //var signTime = ""
    
    //vars used for recording and recognizing speech
    var audioEngine = AVAudioEngine()
    var speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    var request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var spokenWordsArray = [[String]]()
    var tempSpokenArray = [String]()
    
    //vars to record acceleration in iPad
    let manager = CMMotionManager()
    var accelData = [CMAcceleration]()
    
    //audio recorder
    var audioRecorder: MyAudioRecorder!
    
    //file writer
    var fileWriter: FileWriter!
    
    
    //------------copying from signvc--------
    // drawing variables
    var lastPoint = CGPoint.zero
    var brushWidth: CGFloat = 5.0
    var opacity: CGFloat = 1.0
    var swiped = false
    var pickedUp: Int = 0
    
    var demo = true // demo is displayed until the user taps
    
    // timing variables
    var beginTime = NSDate().timeIntervalSince1970
    var endTime = NSDate().timeIntervalSince1970
    var resetTime = true
    var beganDrawing = false
    
    // point struct
    struct drawPoint {
        var point = CGPoint()
        var time  = Double()
        
        init(point: CGPoint, time: Double) {
            self.point = point
            self.time = time
        }
    }
    var points = [drawPoint]() // holds all the points the user draws
    
    var maxX: Double = 0.0
    var maxY: Double = 0.0
    var maxZ: Double = 0.0
    
    var signatureImage = UIImage()
    
    
    //-------end copy from signvc------------------
    
    
    override func viewDidLoad() {
        /*
        let initials:String = initialsText
        /*if initials.isEmpty{
         return
         }*/*/
        let fileName = "\(initialsText)"
        print("file name of narration writer: \(fileName)")
        
        fileWriter = FileWriter.sharedInstance
        fileWriter.setFileName(name: fileName)
        
        fileWriter.write(text: "\(Utils.timeOnly()), Narration Game Begin")

        
        
        //initialize the recorder, singletone instance
        audioRecorder = MyAudioRecorder.sharedInstance
        audioRecorder.startRecording(fileName: "\(fileName)_sentence_\(Date().timeIntervalSince1970)")
        
        //initialize file writer
        fileWriter = FileWriter.sharedInstance
        
    }
    
    func simpleFormattedDateTime(date:Date)-> String{
        let dateFormatter:DateFormatter? = DateFormatter()
        dateFormatter!.dateFormat = "MM_dd_yy_HH_mm_ss"
        if let currentTime = dateFormatter!.string(from: date) as String?{
            return currentTime
        } else{
            return ""
        }
    }
    

    /*
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
     */
    
    // MARK: - Core Data
    
    func saveResult(time: Double, maxX: Double, maxY: Double, maxZ: Double) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity: SignatureResult =  NSEntityDescription.insertNewObject(forEntityName: "SignatureResult", into: managedContext) as! SignatureResult
        
        entity.date = NSDate()
        entity.time = time
        entity.maxXAcceleration = maxX
        entity.maxYAcceleration = maxY
        entity.maxZAcceleration = maxZ
        
        let imageData = NSData(data: UIImageJPEGRepresentation(signatureImage, 1.0)!)
        
        entity.image = imageData
        
        for point in points {
            let newPoint: Point =  NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedContext) as! Point
            newPoint.time = point.time
            newPoint.x = Float(point.point.x)
            newPoint.y = Float(point.point.y)
            newPoint.signatureResult = entity
        }
        /*
         for acceleration in accelerations {
         let newAccel: StylusAcceleration =  NSEntityDescription.insertNewObject(forEntityName: "StylusAcceleration", into: managedContext) as! StylusAcceleration
         newAccel.time = acceleration.time
         newAccel.x = acceleration.acceleration.x
         newAccel.y = acceleration.acceleration.y
         newAccel.z = acceleration.acceleration.z
         newAccel.signatureResult = entity
         }
         */
        for acceleration in accelData {
            let val: DeviceAcceleration = NSEntityDescription.insertNewObject(forEntityName: "DeviceAcceleration", into: managedContext) as! DeviceAcceleration
            val.x = acceleration.x
            val.y = acceleration.y
            val.z = acceleration.z
            val.signatureResult = entity
        }
        do {
            try managedContext.save()
            signatureResults.append(entity)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    
    @IBAction func doneAction(_ sender: Any) {
        //if (initialsTextField.text?.isEmpty)!{
        //return
        //}
        
        fileWriter.write(text: "\(Utils.timeOnly()), Narration Game End")
        audioRecorder.stop()
        
        
        
        self.navigationController?.popViewController(animated: true)
        
    }
    

    
}

