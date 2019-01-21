//
//  SignatureViewController.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 4/13/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import UIKit
import CoreGraphics
import CoreData
import Photos

class SignatureViewController: UIViewController, JotStrokeDelegate, UIGestureRecognizerDelegate {
    
    //initials from consent vc
    var initialsText = ""
    
    //file writer
    var fileWriter: FileWriter!

    // persistence
    let defaults = UserDefaults.standard
    var signatureResults = [SignatureResult]()
    
    // Adonit Stylus
    let motionManager = JotStylusMotionManager()
    
    // views
    @IBOutlet weak var signingView: UIView!
    @IBOutlet weak var drawView: UIImageView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var stylusSettingsView: UIView!
    @IBOutlet weak var nextGameButton: UIButton!

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
    
    // acceleration struct and variables
    struct stylusAccel {
        var acceleration = CMAcceleration()
        var time = Double()
        
        init (acceleration: CMAcceleration, time: Double) {
            self.acceleration = acceleration
            self.time = time
        }
    }
    var accelerations = [stylusAccel]() // holds all the acceleration data
    
    var maxX: Double = 0.0
    var maxY: Double = 0.0
    var maxZ: Double = 0.0
    
    @IBOutlet weak var accelerationLabel: UILabel!
    
    var signatureImage = UIImage()
    
    //iPad acceleration data vars
    let manager = CMMotionManager()
    var accelData = [CMAcceleration]()
    
   
    
    
    override func viewWillAppear(_ animated: Bool) {
        // fetches any previous results from the activity using core data,
        // the results are displayed on the info page
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest:NSFetchRequest<SignatureResult> = SignatureResult.fetchRequest()
        
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            signatureResults = fetchResults
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.jotStylusConnectionChanged(_:)), name: NSNotification.Name(rawValue: JotStylusManagerDidChangeConnectionStatus), object: nil)
        
        resetTime = true
        points.removeAll()
        accelerations.removeAll()
        pickedUp = 0
        
        
        
        // Adonit Stylus
        JotStylusManager.sharedInstance().jotStrokeDelegate = self
        JotStylusManager.sharedInstance().register(self.drawView)
        
        // status view controller (icon in bottom right corner of view)
        let statusViewController = UIStoryboard.instantiateInitialJotViewController();
        statusViewController?.view.frame = stylusSettingsView.bounds;
        stylusSettingsView.backgroundColor = UIColor.clear
        stylusSettingsView.addSubview((statusViewController?.view)!);
        addChildViewController(statusViewController!);
        
        // enable the manager
        JotStylusManager.sharedInstance().enable()
        let enabled = JotStylusManager.sharedInstance().isEnabled
        NSLog("enabled: \(enabled)")
        
        // start accelerometer updates
        JotStylusManager.sharedInstance().jotStylusMotionManager.startAccelerometerUpdates(to: OperationQueue.current, withHandler: {
            [weak self] (data: JotStylusAccelerometerData?, error: Error?) in
            
            if (error != nil)
            {
                NSLog("Error: \(String(describing: error))")
            } else {
                // update label
                self?.accelerationLabel.text = "X: \((data?.acceleration.x)!)"
                // record acceleration
                self?.accelerations.append(stylusAccel(acceleration: (data?.acceleration)!, time: (NSDate().timeIntervalSince1970 - (self?.beginTime)!)))
            }
        })
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Buttons

    @IBAction func resetButton(_ sender: Any) {
        
        drawView.image = nil // remove any points drawn on the screen
        resetTime = true
        beganDrawing = false
        points.removeAll()
        accelerations.removeAll()
        pickedUp = 0
        resultImageView.image = nil
    }
    @IBAction func nextGameButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toTraceGame", sender: self.parent)
         //self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        
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
        resultImageView.image = signatureImage
        
        //resultImageView.setNeedsDisplay()
        
        // find max acceleration values
        for accel in accelerations {
            if abs(accel.acceleration.y) > maxX  {
                maxX = accel.acceleration.x
            }
            if abs(accel.acceleration.y) > maxY {
                maxY = accel.acceleration.y
            }
            if abs(accel.acceleration.z) > maxZ {
                maxZ = accel.acceleration.z
            }
        }
        
        self.findAcceleration()
        
        // persist
        self.saveResult(time: totalTime, maxX: maxX, maxY: maxY, maxZ: maxZ)
    
        // reset variables
        drawView.image = nil
        accelerations.removeAll()
        points.removeAll()
        pickedUp = 0
        resetTime = true
        beganDrawing = false
        
         self.navigationController?.popViewController(animated: true)
        
        
        
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
            
            beginTime = NSDate().timeIntervalSince1970
        }
        swiped = false
        let touch = touches.first
        lastPoint = (touch?.location(in: self.view))!
        print(lastPoint)
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
        for acceleration in accelerations {
            let newAccel: StylusAcceleration =  NSEntityDescription.insertNewObject(forEntityName: "StylusAcceleration", into: managedContext) as! StylusAcceleration
            newAccel.time = acceleration.time
            newAccel.x = acceleration.acceleration.x
            newAccel.y = acceleration.acceleration.y
            newAccel.z = acceleration.acceleration.z
            newAccel.signatureResult = entity
        }
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SignatureInfoViewController {
            dest.signatureResults = signatureResults // any results saved in core data passed
        }
    }
    

    // MARK: - Adonit Stylus
    
    func jotStylusConnectionChanged(_ note: Notification) {
        guard let item = note.userInfo?[JotStylusManagerDidChangeConnectionStatusStatusKey] as? NSNumber,
            let _ = JotConnectionStatus(rawValue: item.uintValue) else {
                print("Problem parsing jot connection notification!")
                return
        }
    }
    
    // functions below conform to the JotStrokeDelegate Protocol
    /** Suggest to enable gestures when the pen is not down as there are no potential conflicts*/
    public func jotSuggestsToEnableGestures() {
        NSLog("jot suggest to enable gestures")
    }
    
    /** Suggest to disable gestures when the pen is down to prevent conflict*/
    public func jotSuggestsToDisableGestures() {
        NSLog("jot suggests to disable gestures")
    }
    
    /** Called when strokes by the jot stylus are cancelled @param jotStroke where stylus cancels */
    public func jotStylusStrokeCancelled(_ stylusStroke: JotStroke) {
        NSLog("jot stylus stroke cancelled")
    }
    
    /** Called when the jot stylus is lifted from the screen @param jotStrokes where stylus ends */
    public func jotStylusStrokeEnded(_ stylusStroke: JotStroke) {
        NSLog("jot stylus stroke ended")
    }
    
    /** Called when the jot stylus moves across the screen @param jotStroke where stylus is moving */
    public func jotStylusStrokeMoved(_ stylusStroke: JotStroke) {
        NSLog("jot stylus stroke moved")
    }
    
    /** Called when the stylus begins a stroke event @param jotStroke where the stylus began its stroke */
    public func jotStylusStrokeBegan(_ stylusStroke: JotStroke) {
        NSLog("jot stylus Stroke Began")
    }
}

