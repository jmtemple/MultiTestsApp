//
//  NarrationWriterViewController.swift
//  NarrationWriter
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

class NarrationWriterViewController: UIViewController, SFSpeechRecognizerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate{
    
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
    
    @IBOutlet weak var signingView: SigningView!
    @IBOutlet weak var drawView: UIImageView!
    
    
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
        
        /*let initials:String = initialsText
        /*if initials.isEmpty{
            return
        }*/*/
        let fileName = "\(initialsText)"
        print("file name of narration writer: \(fileName)")
        
        fileWriter = FileWriter.sharedInstance
        fileWriter.setFileName(name: fileName)
        
        fileWriter.write(text: "\(Utils.timeOnly()), Narration Writer Game Begin")

        
        
        //initialize the recorder, singletone instance
        audioRecorder = MyAudioRecorder.sharedInstance
        audioRecorder.startRecording(fileName: "\(fileName)_narrationwriter_\(Date().timeIntervalSince1970)")
        
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
    
    
    func findAcceleration(){
        var totalx: Double = 0
        var totaly: Double = 0
        var totalz: Double = 0
        for point in self.accelData {
            totalx += point.x
            totaly += point.y
            totalz += point.z
        }
        print("Averages:")
        print("x: \(totalx / Double(self.accelData.count)) y: \(totaly / Double(self.accelData.count)) z: \(totalz / Double(self.accelData.count))")
        
    }
    
    // MARK: - Drawing Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (resetTime) {
            //nextGameButton.isHidden = true
            beginTime = NSDate().timeIntervalSince1970
        }
        swiped = false
        let touch = touches.first
        lastPoint = (touch?.location(in: self.view))!
        //lastPoint = (touch?.location(in: self.drawView))!
        print(lastPoint)
        fileWriter.write(text: "\(Utils.currentLocalTime()),\(lastPoint.x),\(lastPoint.y)")
        points.append(drawPoint(point: lastPoint, time: NSDate().timeIntervalSince1970))
        resetTime = false
        beganDrawing = true
        
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        drawView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        context!.setLineCap(CGLineCap.round)
        context!.setLineWidth(brushWidth)
        context!.setStrokeColor(red: 0, green: 0, blue: 255, alpha: 1.0)
        context!.setBlendMode(CGBlendMode.normal)
        
        context!.strokePath()
        
        drawView.image = UIGraphicsGetImageFromCurrentImageContext()
        drawView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        swiped = true
        let touch = touches.first
        let currentPoint = touch?.location(in: view)
        drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint!)
        lastPoint = currentPoint!
        print(lastPoint)
        fileWriter.write(text: "\(Utils.currentLocalTime()),\(lastPoint.x),\(lastPoint.y)")
        points.append(drawPoint(point: lastPoint, time: NSDate().timeIntervalSince1970))
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !swiped {
            // draw a single point
            drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
        }
        
        UIGraphicsBeginImageContext(drawView.frame.size)
        drawView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        drawView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
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
        fileWriter.write(text: "\(Utils.timeOnly()), Narration Writer Game End")
        audioRecorder.stop()
        
        
        if (points.count > 0) {
            endTime = NSDate().timeIntervalSince1970
        }
        
        // calculate total time
        var totalTime = endTime - beginTime
        
        if beganDrawing == false {
            totalTime = 0.0
        }
        
        // get image of the signature and save to the device's photo album
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        signatureImage = renderer.image { ctx in
            drawView.drawHierarchy(in: drawView.bounds, afterScreenUpdates: true)
        }
        UIImageWriteToSavedPhotosAlbum(signatureImage, nil, nil, nil)
        //resultImageView.image = signatureImage
        //resultImageView.setNeedsDisplay()
        
        // find max acceleration values
        /*for accel in accelerations {
         if abs(accel.acceleration.y) > maxX  {
         maxX = accel.acceleration.x
         }
         if abs(accel.acceleration.y) > maxY {
         maxY = accel.acceleration.y
         }
         if abs(accel.acceleration.z) > maxZ {
         maxZ = accel.acceleration.z
         }
         }*/
        
        self.findAcceleration()
        
        // persist
        self.saveResult(time: totalTime, maxX: maxX, maxY: maxY, maxZ: maxZ)
        
        // reset variables
        drawView.image = nil
        //accelerations.removeAll()
        points.removeAll()
        pickedUp = 0
        resetTime = true
        beganDrawing = false
        
        //self.nextGameButton.isHidden = false
        
        //self.delegate?.childViewControllerResponse(refernceAnswer: "signed...\(self.indexInParent)")
        //self.navigationController?.popViewController(animated: true)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func resetAction(_ sender: Any) {
        drawView.image = nil // remove any points drawn on the screen
        resetTime = true
        beganDrawing = false
        points.removeAll()
        //accelerations.removeAll()
        pickedUp = 0
        //resultImageView.image = nil
        
    }
    
    
}

