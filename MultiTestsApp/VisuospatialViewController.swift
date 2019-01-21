//
//  VisuospatialViewController.swift
//  MultiTestsApp
//
//  Created by Caroline Braun on 3/6/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import UIKit
import CoreGraphics
import CoreData

class VisuospatialViewController: UIViewController, JotStrokeDelegate, UIGestureRecognizerDelegate {
    
    //initials from consent vc
    var initialsText = ""
    
    //file writer
    var fileWriter: FileWriter!
    
    //game index
    var gameIndex = 0

    @IBOutlet weak var bgroundImageView: UIImageView!
    @IBOutlet weak var drawView: UIImageView!
    @IBOutlet weak var stylusSettingsView: UIView!
    //@IBOutlet weak var nextGameButton: UIButton!
    
    let motionManager = JotStylusMotionManager()
    
    // keeps track of which device the app is running on (iPad vs iPhone)
    var device: String = "" // set in prepareForSegue() in MainTableViewController
    
    // drawing variables
    var lastPoint = CGPoint.zero
    var brushWidth: CGFloat = 5.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    // persistence
    let defaults = UserDefaults.standard
    var visResults = [VisResult]()
    var distances = [Double]()          //this is used in endGame and saveData

    // timing variables
    var beginTime = NSDate().timeIntervalSince1970
    var endTime = NSDate().timeIntervalSince1970
    var resetTime = true
    var beganDrawing = false
    
    //iPad acceleration vars
    let manager = CMMotionManager()
    var accelData = [CMAcceleration]()
    
    //image capture
    var traceImage = UIImage()
    
    // point struct
    struct tracePoint {
        var point = CGPoint()
        var time  = Double()
        
        init(point: CGPoint, time: Double) {
            self.point = point
            self.time = time
        }
    }
    
    // acceleration struct and variables
    struct stylusAccel {
        var acceleration = CMAcceleration()
        var time = Double()
        
        init (acceleration: CMAcceleration, time: Double) {
            self.acceleration = acceleration
            self.time = time
        }
    }
    
    var maxX: Double = 0.0
    var maxY: Double = 0.0
    var maxZ: Double = 0.0
    
    var points = [tracePoint]() // holds all the points the user draws
    var accelerations = [stylusAccel]() // holds all the acceleration data
    var closestPoints = [tracePoint]()
    
    
    var targetPoints: [CGPoint] = [CGPoint(x: 297.5, y: 328.5), //instance 1:3 instance 2:7
        CGPoint(x: 474.0, y: 260.0),   //instance 1:6 instance 2:10
        CGPoint(x: 557.5, y: 378.5),   //instance 1:7 instance 2:5
        CGPoint(x: 412.5, y: 433.5),   //instance 1:5 instance 2:6
        CGPoint(x: 583.0, y: 570.0),   //instance 1:9 instance 2:4
        CGPoint(x: 267.5, y: 813.0),   //instance 1:10 instance 2:1
        CGPoint(x: 374.5, y: 645.5),   //instance 1:8 instance 2:2
        CGPoint(x: 211.5, y: 559.0),   //instance 1:4 instance 2:3
        CGPoint(x: 108.0, y: 330.5),   //instance 1:2 instance 2:8
        CGPoint(x: 360.5, y: 219.5)]   //instance 1:1 instance 2:9

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (device == "iPhone") {
            //stylusSettingsView height and width
        }
        
        //load background image view
        if gameIndex == 0{
            bgroundImageView.image = UIImage(named: "bground")
        }else{
            bgroundImageView.image = UIImage(named: "bground1")
        }
        
        
        resetTime = true
        //nextGameButton.isHidden = true
        
        let fileName = "\(initialsText)"
        
        fileWriter = FileWriter.sharedInstance
        fileWriter.setFileName(name: fileName)
        
        fileWriter.write(text: "\(Utils.timeOnly()), Visuospatial Game Begins \(gameIndex)")

        
        let alert = UIAlertController(title: "Instructions", message: "Connect the shapes in numerical order from 1-10", preferredStyle: UIAlertControllerStyle.alert)
        //let alert = UIAlertController(title: "This time, please repeat the following phrase as you trace the shapes in the air: We saw several wild animals", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        // status view controller (icon in bottom right corner of view)
        let statusViewController = UIStoryboard.instantiateInitialJotViewController();
        statusViewController?.view.frame = stylusSettingsView.bounds;
        stylusSettingsView.backgroundColor = UIColor.clear
        stylusSettingsView.addSubview((statusViewController?.view)!);
        addChildViewController(statusViewController!);
        
        // Adonit Stylus
        JotStylusManager.sharedInstance().jotStrokeDelegate = self
        JotStylusManager.sharedInstance().register(self.drawView)
        
        // enable the manager
        JotStylusManager.sharedInstance().enable()
        let enabled = JotStylusManager.sharedInstance().isEnabled
        NSLog("enabled: \(enabled)")
        
        //start ipad acceleration data colleciton
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
    
    @IBAction func resetButton(_ sender: Any) {
        drawView.image = nil // remove any points drawn on the screen
        points.removeAll()
        resetTime = true
        beganDrawing = false
    }
    
    @IBAction func submitButton(_ sender: Any) {
        
        
        
        endTime = NSDate().timeIntervalSince1970
        var totalTime = endTime - beginTime
        
        if beganDrawing == false {
            totalTime = 0.0
        }
        let totalTimeStr = String(format: "%.2f", totalTime)
        NSLog("time: \(totalTimeStr)")
        
        //image capture
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        traceImage = renderer.image { ctx in
            drawView.drawHierarchy(in: drawView.bounds, afterScreenUpdates: true)
        }
        UIImageWriteToSavedPhotosAlbum(traceImage, nil, nil, nil)
        if(beganDrawing){
            endGame()
        }
        self.navigationController?.popViewController(animated: true)
        
        fileWriter.write(text: "\(Utils.timeOnly()), Visuospatial Game End \(gameIndex)")

    }
    
    func endGame(){
        var min:Double
        var timeSeg:Double
        
        var times = [Double]()
        var tempPoint: tracePoint?
        for target in targetPoints{
            min = 1000000
            timeSeg = 0
            for point in points{
                if(Double(distance(target, point.point)) < min){
                    min = Double(distance(target, point.point))
                    timeSeg = point.time
                    tempPoint = point
                }
            }
            closestPoints.append(tempPoint!)
            distances.append(min)
            times.append(timeSeg)
        }
        var totaltime:Double = 0
        var my_time:Double
        var count:Int = 0
        for timeSegments in times{
            my_time = timeSegments - (beginTime + totaltime)
            totaltime = my_time + totaltime
            print("Time to object \(count): \(my_time)")
            print("Distance from that point: \(distances[count])")
            count += 1
        }
        //nextGameButton.isHidden = false
        self.findAcceleration()
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
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
    
    //core data
    func saveResult() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity: VisResult =  NSEntityDescription.insertNewObject(forEntityName: "VisResult", into: managedContext) as! VisResult
        
        entity.date = NSDate()
        
        for point in points {
            let newPoint: Point =  NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedContext) as! Point
            newPoint.time = point.time
            newPoint.x = Float(point.point.x)
            newPoint.y = Float(point.point.y)
            newPoint.visResult = entity
        }
        for acceleration in accelerations {
            let newAccel: StylusAcceleration =  NSEntityDescription.insertNewObject(forEntityName: "StylusAcceleration", into: managedContext) as! StylusAcceleration
            newAccel.time = acceleration.time
            newAccel.x = acceleration.acceleration.x
            newAccel.y = acceleration.acceleration.y
            newAccel.z = acceleration.acceleration.z
            newAccel.visResult = entity
        }
        for acceleration in self.accelData {
            let newAccel: DeviceAcceleration =  NSEntityDescription.insertNewObject(forEntityName: "DeviceAcceleration", into: managedContext) as! DeviceAcceleration
            newAccel.x = acceleration.x
            newAccel.y = acceleration.y
            newAccel.z = acceleration.z
            newAccel.visResult = entity
        }
        var index:Int16 = 0
        for point in closestPoints {
            let newPoint: ClosestPoint =  NSEntityDescription.insertNewObject(forEntityName: "ClosestPoint", into: managedContext) as! ClosestPoint
            newPoint.time = point.time
            newPoint.x = Float(point.point.x)
            newPoint.y = Float(point.point.y)
            newPoint.distance = self.distances[Int(index)]
            newPoint.dotValue = index + 1
            newPoint.visResult = entity
            index += 1
        }
        
        do {
            try managedContext.save()
            visResults.append(entity)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
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
        print(lastPoint) 
        points.append(tracePoint(point: lastPoint, time: NSDate().timeIntervalSince1970))
        resetTime = false
        beganDrawing = true
        fileWriter.write(text: "\(Utils.currentLocalTime()),\(lastPoint.x),\(lastPoint.y)")
        
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
        points.append(tracePoint(point: lastPoint, time: NSDate().timeIntervalSince1970))
        fileWriter.write(text: "\(Utils.currentLocalTime()),\(lastPoint.x),\(lastPoint.y)")
        
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
