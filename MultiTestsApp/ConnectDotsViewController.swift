//
//  ConnectDotsViewController.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 3/29/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import UIKit
import CoreGraphics
import CoreData

class ConnectDotsViewController: UIViewController, JotStrokeDelegate, UIGestureRecognizerDelegate {

    // keeps track of which device the app is running on (iPad vs iPhone)
    var device: String = "" // set in prepareForSegue() in MainTableViewController
    var width: Double = 0.0
    var height: Double = 0.0
    
    // persistence
    let defaults = UserDefaults.standard
    var connectResults = [ConnectResult]()
    
    // ipad acceleration data vars
    let manager = CMMotionManager()
    var accelData = [CMAcceleration]()
    
    // Adonit Stylus
    let motionManager = JotStylusMotionManager()
    
    // views
    @IBOutlet weak var drawImage: UIImageView!
    @IBOutlet weak var drawView: UIImageView!
    @IBOutlet weak var stylusSettingsView: UIView!
    @IBOutlet weak var dotsView: DotsView!
    @IBOutlet weak var nextGameButton: UIButton!
    
    // drawing variables
    var lastPoint = CGPoint.zero
    var brushWidth: CGFloat = 5.0
    var opacity: CGFloat = 1.0
    var swiped = false
    var pickedUp: Int = 0
    var red: CGFloat = 0
    var blue: CGFloat = 255
    var green: CGFloat = 0
    var image = 0 // 0 = flower, 1 = leaf, 2 = heart
    
    var demo = true // demo is displayed until the user taps
    
    // timing variables
    var beginTime = NSDate().timeIntervalSince1970
    var endTime = NSDate().timeIntervalSince1970
    var resetTime = true
    var beganDrawing = false
    
    //image capture
    var traceImage = UIImage()
    
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
    var closestPoints = [drawPoint]() // holds the closest 16 points
    var distances = [Double]() // holds the distances to each of the 16 drawing points
    
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
    
    @IBOutlet weak var accelerationLabel: UILabel!
    
    var maxX: Double = 0.0
    var maxY: Double = 0.0
    var maxZ: Double = 0.0
    
    // array contains all the dots of the drawing (iPad)
    var flowerDots: [CGPoint] = [CGPoint(x: 394.5, y: 151.0),
                                 CGPoint(x: 479.0, y: 218.0),
                                 CGPoint(x: 583.5, y: 241.0),
                                 CGPoint(x: 592.5, y: 337.5),
                                 CGPoint(x: 662.0, y: 427.0),
                                 CGPoint(x: 598.0, y: 505.5),
                                 CGPoint(x: 586.0, y: 630.5),
                                 CGPoint(x: 482.5, y: 631.0),
                                 CGPoint(x: 391.5, y: 698.0),
                                 CGPoint(x: 307.5, y: 627.0),
                                 CGPoint(x: 194.0, y: 621.5),
                                 CGPoint(x: 185.0, y: 511.0),
                                 CGPoint(x: 118.0, y: 424.0),
                                 CGPoint(x: 188.0, y: 337.5),
                                 CGPoint(x: 214.0, y: 231.5),
                                 CGPoint(x: 310.0, y: 218.0)]
    
    var leafDots: [CGPoint] = [CGPoint(x: 621.12, y: 215.0),
                               CGPoint(x: 509.75, y: 295.0),
                               CGPoint(x: 378.0, y: 354.9),
                               CGPoint(x: 240.0, y: 416.25),
                               CGPoint(x: 171.75, y: 538.75),
                               CGPoint(x: 141.5, y: 672.5),
                               CGPoint(x: 168.0, y: 782.75),
                               CGPoint(x: 76.0, y: 826.0),
                               CGPoint(x: 100.5, y: 865.5),
                               CGPoint(x: 194.25, y: 817.75),
                               
                               CGPoint(x: 351.5, y: 843.0),
                               CGPoint(x: 489.5, y: 802.5),
                               CGPoint(x: 592.0, y: 714.0),
                               CGPoint(x: 646.5, y: 599.5),
                               CGPoint(x: 669.0, y: 479.5),
                               CGPoint(x: 658.5, y: 339.5)]
    
    var heartDots: [CGPoint] = [CGPoint(x: 383.5, y: 358.0),
                                CGPoint(x: 482.75, y: 270.25),
                                CGPoint(x: 625.5, y: 287.25),
                                CGPoint(x: 685.75, y: 461.5),
                                CGPoint(x: 645.9, y: 545.9),
                                CGPoint(x: 533.5, y: 610.5),
                                CGPoint(x: 463.5, y: 698.0),
                                CGPoint(x: 388.0, y: 773.0),
                                CGPoint(x: 328.25, y: 707.00),
                                CGPoint(x: 205.75, y: 610.5),
                                CGPoint(x: 105.0, y: 544.0),
                                CGPoint(x: 86.5, y: 439.5),
                                CGPoint(x: 143.0, y: 287.25),
                                CGPoint(x: 271.0, y: 250.75)]
    
    override func viewWillAppear(_ animated: Bool) {
        // fetches any previous results from the activity using core data,
        // the results are displayed on the info page (top right button on view)
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest:NSFetchRequest<ConnectResult> = ConnectResult.fetchRequest()
        
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            connectResults = fetchResults
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.jotStylusConnectionChanged(_:)), name: NSNotification.Name(rawValue: JotStylusManagerDidChangeConnectionStatus), object: nil)
        
        if (device == "iPhone") {
            //stylusSettingsView
        }
        
        nextGameButton.isHidden = true
        
        resetTime = true
        points.removeAll()
        accelerations.removeAll()
        pickedUp = 0
        
        let alert = UIAlertController(title: "Instructions", message: "Connect the dots to complete the image", preferredStyle: UIAlertControllerStyle.alert)
        //let alert = UIAlertController(title: "This time, please repeat the following phrase as you trace the shapes in the air: We saw several wild animals", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
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
        
        dotsView.isHidden = true
        
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
        
        //start reading ipad acceleration data
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
        
        // recalculate the locations of the dots if device is not an ipad
        width = Double(self.view.bounds.width)
        height = Double(self.view.bounds.height)
        
        // NSLog("width: \(width)")
        // NSLog("height: \(height)")
        
        if (width != 768) || (height != 1024) {

            for index in 0...15 {
                let oldDot = flowerDots[index]
                let newDot = CGPoint(x: (oldDot.x * CGFloat(width/768.0)), y: (oldDot.y * CGFloat(height/1024.0)))
                flowerDots[index] = newDot
            }
            for index in 0...15 {
                let oldDot = leafDots[index]
                let newDot = CGPoint(x: (oldDot.x * CGFloat(width/768.0)), y: (oldDot.y * CGFloat(height/1024.0)))
                leafDots[index] = newDot
            }
            for index in 0...13 {
                let oldDot = heartDots[index]
                let newDot = CGPoint(x: (oldDot.x * CGFloat(width/768.0)), y: (oldDot.y * CGFloat(height/1024.0)))
                heartDots[index] = newDot
            }
        }
        
        dotsView.points = flowerDots
        dotsView.setNeedsDisplay()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func resetButton(_ sender: Any) {
        drawView.image = nil // remove any points drawn on the screen
        resetTime = true
        beganDrawing = false
        points.removeAll()
        accelerations.removeAll()
        pickedUp = 0
    }
    
    @IBAction func nextGameButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toFallingBall", sender: self.parent)
    }
    
    //@IBAction func changeImageButton(_ sender: Any) {
    func changeImage(){
        if (image == 0) { // change from flower to leaf
            drawImage.image = #imageLiteral(resourceName: "leaf")
            image = 1
            dotsView.points = leafDots
            red = 0
            blue = 0
            green = 150
            
        } else if (image == 1) { // leaf to heart
            drawImage.image = #imageLiteral(resourceName: "heart")
            image = 2
            dotsView.points = heartDots
            red = 255
            blue = 0
            green = 0
        } else { // heart to flower
            image = 0
            drawImage.image = #imageLiteral(resourceName: "flower")
            dotsView.points = flowerDots
            red = 0
            blue = 255
            green = 0
        }
        drawView.image = nil
        dotsView.setNeedsDisplay()
    }
    
    @IBAction func submitButton(_ sender: Any) {
        
        if (points.count > 0) {
        
            // calculate total time
            endTime = NSDate().timeIntervalSince1970
            var totalTime = endTime - beginTime
        
            if beganDrawing == false {
                totalTime = 0.0
            }
            let totalTimeStr = String(format: "%.2f", totalTime)
            
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
            
            findClosestPoints()
            findAcceleration()
            
            // persistence, save the recently calculated results
            self.saveResult(time: totalTime, maxX: maxX, maxY: maxY, maxZ: maxZ)
            
            // display results
            let alert = UIAlertController(title: "Performance", message: "Total Time: \(totalTimeStr) s\nMax X Accel: \(maxX)\nMax Y Accel: \(maxY)\nMax Z Accel: \(maxZ)\nStylus Picked Up: \(pickedUp) times", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            //image capture
            let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
            traceImage = renderer.image { ctx in
                drawView.drawHierarchy(in: drawView.bounds, afterScreenUpdates: true)
            }
            UIImageWriteToSavedPhotosAlbum(traceImage, nil, nil, nil)
            
            // reset activity
            points.removeAll()
            drawView.image = nil
            beganDrawing = false
            resetTime = true
            pickedUp = 0
            accelerations.removeAll()
            distances.removeAll()
            closestPoints.removeAll()
            
        }
        if(image != 2){
            self.changeImage()
        } else {
            nextGameButton.isHidden = false
        }
    }
    
    // MARK: - Analytics
    func findClosestPoints() {
        
        // initialize distances
        if (image == 2) {
            for _ in 0...13 {
                distances.append(500.0)
                closestPoints.append(points[0])
            }
        } else {
            for _ in 0...15 {
                distances.append(500.0)
                closestPoints.append(points[0])
            }
        }
        
        if (image == 0) { // flower
            for index in 0...15  {
                for drawPoint in points {
                    let newDistance = distanceBetween(p1: drawPoint.point, p2: flowerDots[index])
                    if newDistance < distances[index] {
                        distances[index] = newDistance
                        closestPoints[index] = drawPoint
                    }
                }
            }
        } else if (image == 1) { // leaf
            for index in 0...15  {
                for drawPoint in points {
                    let newDistance = distanceBetween(p1: drawPoint.point, p2: leafDots[index])
                    if newDistance < distances[index] {
                        distances[index] = newDistance
                        closestPoints[index] = drawPoint
                    }
                }
            }
        } else { // heart
            for index in 0...13  {
                for drawPoint in points {
                    let newDistance = distanceBetween(p1: drawPoint.point, p2: heartDots[index])
                    if newDistance < distances[index] {
                        distances[index] = newDistance
                        closestPoints[index] = drawPoint
                    }
                }
            }
        }
    }
    
    func distanceBetween(p1: CGPoint, p2: CGPoint) -> Double {
        // calculates distance between two points
        let xDist = Double(p1.x - p2.x)
        let yDist = Double(p1.y - p2.y)
        let distance = sqrt((xDist * xDist) + (yDist * yDist))
        return distance
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
        if (demo) && !(stylusSettingsView.frame.contains((touches.first?.location(in: view))!)) {
            
            // make sure the stylus is connected before the user can begin drawing
            if !(JotStylusManager.sharedInstance().isStylusConnected) {
                let alert = UIAlertController(title: "Stylus Not Connected", message: "The Adonit Pixel stylus must be connected for the activity. Use the stylus icon in the bottom right to help.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                accelerationLabel.isHidden = true
                demo = false
                
            }
        } else if !(stylusSettingsView.frame.contains((touches.first?.location(in: view))!)) {
            if (resetTime) {
                beginTime = NSDate().timeIntervalSince1970
                nextGameButton.isHidden = true
            }
            if (beganDrawing) {
                pickedUp += 1
            }
            swiped = false
            let touch = touches.first
            lastPoint = (touch?.location(in: self.view))!
            resetTime = false
            beganDrawing = true
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        if !(demo) && fromPoint.x > 0 && fromPoint.y > 0 {
            beganDrawing = true
            UIGraphicsBeginImageContext(view.frame.size)
            let context = UIGraphicsGetCurrentContext()
            drawView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            
            context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            
            context!.setLineCap(CGLineCap.round)
            context!.setLineWidth(brushWidth)
            context!.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
            context!.setBlendMode(CGBlendMode.normal)
            
            context!.strokePath()
            
            drawView.image = UIGraphicsGetImageFromCurrentImageContext()
            drawView.alpha = opacity
            UIGraphicsEndImageContext()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !(demo) && !(stylusSettingsView.frame.contains((touches.first?.location(in: view))!)) {
            beganDrawing = true
            swiped = true
            let touch = touches.first
            let currentPoint = touch?.location(in: view)
            let currentTime = NSDate().timeIntervalSince1970 - beginTime
            let currentDrawPoint = drawPoint(point: (touch?.location(in: view))!, time: currentTime)
            points.append(currentDrawPoint)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint!)
            lastPoint = currentPoint!
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !(demo) {
            beganDrawing = true
            if !swiped {
                // draw a single point
                // NSLog("X: \(lastPoint.x), Y: \(lastPoint.y)")
                drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
                points.append(drawPoint(point: lastPoint, time: NSDate().timeIntervalSince1970 - beginTime))
            }
            
            UIGraphicsBeginImageContext(drawView.frame.size)
            drawView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
            drawView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ConnectInfoViewController {
            dest.device = self.device // iPhone vs. iPad
            dest.connectResults = connectResults // any results saved in core data passed
        }
    }
    
    // MARK: - Core Data
    
    func saveResult(time: Double, maxX: Double, maxY: Double, maxZ: Double) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity: ConnectResult =  NSEntityDescription.insertNewObject(forEntityName: "ConnectResult", into: managedContext) as! ConnectResult
        
        entity.date = NSDate()
        entity.time = time
        entity.maxXAcceleration = maxX
        entity.maxYAcceleration = maxY
        entity.maxZAcceleration = maxZ

        for point in points {
            let newPoint: Point =  NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedContext) as! Point
            newPoint.time = point.time
            newPoint.x = Float(point.point.x)
            newPoint.y = Float(point.point.y)
            newPoint.connectResult = entity
        }
        for acceleration in accelerations {
            let newAccel: StylusAcceleration =  NSEntityDescription.insertNewObject(forEntityName: "StylusAcceleration", into: managedContext) as! StylusAcceleration
            newAccel.time = acceleration.time
            newAccel.x = acceleration.acceleration.x
            newAccel.y = acceleration.acceleration.y
            newAccel.z = acceleration.acceleration.z
            newAccel.connectResult = entity
        }
        for acceleration in self.accelData {
            let newAccel: DeviceAcceleration =  NSEntityDescription.insertNewObject(forEntityName: "DeviceAcceleration", into: managedContext) as! DeviceAcceleration
            newAccel.x = acceleration.x
            newAccel.y = acceleration.y
            newAccel.z = acceleration.z
            newAccel.connectResult = entity
        }
        var index:Int16 = 0
        for point in closestPoints {
            let newPoint: ClosestPoint =  NSEntityDescription.insertNewObject(forEntityName: "ClosestPoint", into: managedContext) as! ClosestPoint
            newPoint.time = point.time
            newPoint.x = Float(point.point.x)
            newPoint.y = Float(point.point.y)
            newPoint.distance = self.distances[Int(index)]
            newPoint.dotValue = index + 1
            newPoint.connectResult = entity
            index += 1
        }
        
        do {
            try managedContext.save()
            connectResults.append(entity)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
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
