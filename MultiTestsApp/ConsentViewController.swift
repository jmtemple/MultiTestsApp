//
//  ConsentViewController.swift
//  PictureGame
//
//  Created by Afzal Hossain on 7/20/18.
//  Copyright © 2018 University of Notre Dame. All rights reserved.
//

import UIKit
import CoreGraphics
import CoreData
import Photos
import CoreMotion
import WebKit

class ConsentViewController: UIViewController, UIGestureRecognizerDelegate, WKUIDelegate {

    //file writer
    var fileWriter: FileWriter!
    
    var firstName = ""
    var lastName = ""
    var birthYear = ""
    var diagnosis = ""

    
    // persistence
    let defaults = UserDefaults.standard
    var signatureResults = [SignatureResult]()

    
    @IBOutlet weak var signingView: SigningView!
    @IBOutlet weak var drawView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pdfView: WKWebView!
    @IBOutlet weak var initialsTextField: UITextField!
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
    
    //iPad acceleration data vars
    let manager = CMMotionManager()
    var accelData = [CMAcceleration]()

    //-------end copy from signvc------------------
    
    var signatureTime:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        //initialize file writer
        fileWriter = FileWriter.sharedInstance
        //signatureTime = "remember_to_change"//Utils.currentLocalTimeForFilename()
        fileWriter.setFileName(name: "\(firstName)_\(lastName)_\(birthYear)_\(diagnosis)_consent_signature")


        navigationController?.navigationBar.topItem?.title = "Consent"

        if let pdfURL = Bundle.main.url(forResource: "consent", withExtension: "pdf", subdirectory: nil, localization: nil)  {
            do {
                let data = try Data(contentsOf: pdfURL)
                let webConfiguration = WKWebViewConfiguration()
                pdfView = WKWebView(frame: CGRect(x:0,y:0,width:view.frame.size.width-40, height:view.frame.size.height), configuration: webConfiguration)
                pdfView.uiDelegate = self
                pdfView.load(data, mimeType: "application/pdf", characterEncodingName:"", baseURL: pdfURL.deletingLastPathComponent())
                //view.addSubview(webView)
                
            }
            catch {
                // catch errors here
            }
            
        }
        
        scrollView.addSubview(pdfView)
        scrollView.showsVerticalScrollIndicator = true


        // Do any additional setup after loading the view.
        
        //---------begin signvc--------
        resetTime = true
        points.removeAll()
        pickedUp = 0

        //start iPad acceleration updates
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to:
        OperationQueue.current!) { (accelerometerData:
            CMAccelerometerData?, NSError) -> Void in
            
            if let data = accelerometerData {
                self.accelData.append(data.acceleration)
            }
            if(NSError != nil) {
                print("\(String(describing: NSError))")
            }
        }

        //---------end signvc--------
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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
        
        ///need to fix later
        /*if (initialsTextField.text?.isEmpty)!{
            return
        }*/
        
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

        
        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "maintablevc") as? MainTableViewController {
            ////need to fix later
            //viewController.initialsText = initialsTextField.text!
            //viewController.signTime = signatureTime
            viewController.firstName = firstName
            viewController.lastName = lastName
            viewController.birthYear = birthYear
            viewController.diagnosis = diagnosis
            
            self.navigationController?.pushViewController(viewController, animated: true)
            /*if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }*/
        }
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
    /*@IBAction func doneButton(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "gamevc") as? PictureGameViewController {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }

    }*/
}
