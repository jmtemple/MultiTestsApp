//
//  GameViewController1.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 10/3/16.
//  Copyright © 2016 NDMobileCompLab. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import Speech
import CoreData
import AVFoundation

class TraceShapeSpeechViewController: UIViewController, JotStrokeDelegate, UIGestureRecognizerDelegate, AVAudioRecorderDelegate {
    
    // keeps track of which device the app is running on (iPad vs iPhone)
    var device: String = "iPhone" // set in prepareForSegue() in MainTableViewController
    
    //initials from consent vc
    var initialsText = ""
    
    // persistence
    let defaults = UserDefaults.standard
    var traceResults = [TraceResult]()
    
    // Adonit Stylus
    let motionManager = JotStylusMotionManager()
    
    //record iPad acceleration
    let manager = CMMotionManager()
    var accelData = [CMAcceleration]()
    
    //record audio 
    var recordingSession: AVAudioSession!
    var AVaudioRecorder: AVAudioRecorder!
    
    
    // views
    @IBOutlet weak var demoView: DemoView!
    @IBOutlet weak var drawView: UIImageView!
    @IBOutlet weak var traceView: TraceView!
    @IBOutlet weak var stylusSettingsView: UIView! // contains an icon that indicates if the stylus is connected
    @IBOutlet weak var bufferView: UIView! // doesn't let users accidentally draw points when trying to tap buttons on the toolbar.
    @IBOutlet weak var nextGameButton: UIButton!
    
    // drawing variables
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0        
    var green: CGFloat = 0.0
    var blue: CGFloat = 255.0
    var brushWidth: CGFloat = 5.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    var demo = true // demo is displayed until the user taps
    var firstSubmit = false
    
    // timing variables
    var beginTime = NSDate().timeIntervalSince1970
    var endTime = NSDate().timeIntervalSince1970
    var resetTime = true
    var beganDrawing = false
    
    //image capture
    var shapeImage = UIImage()
    
    // point struct
    struct tracePoint {
        var point = CGPoint()
        var time  = Double()
        
        init(point: CGPoint, time: Double) {
            self.point = point
            self.time = time
        }
    }
    var points = [tracePoint]() // holds all the points the user draws
    
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
    
    //audio recorder
    var audioRecorder: MyAudioRecorder!
    
    //file writer
    var fileWriter: FileWriter!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        // fetches any previous results from the activity using core data,
        // the results are displayed on the info page (top right button on view)
        super.viewWillAppear(animated)
        
        /*let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest:NSFetchRequest<TraceResult> = TraceResult.fetchRequest()
        
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            //traceResults = fetchResults
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }*/
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.jotStylusConnectionChanged(_:)), name: NSNotification.Name(rawValue: JotStylusManagerDidChangeConnectionStatus), object: nil)
        
        let fileName = "\(initialsText)"
        
        fileWriter = FileWriter.sharedInstance
        fileWriter.setFileName(name: fileName)
        
        fileWriter.write(text: "\(Utils.timeOnly()), Trace Shape with Speech Game Begins")
        fileWriter.write(text: "\(Utils.timeOnly()), FIRST SHAPE BEGIN")
        
        
        //initialize the recorder, singletone instance
        audioRecorder = MyAudioRecorder.sharedInstance
        audioRecorder.startRecording(fileName: "\(fileName)_TracewithSpeech_\(Date().timeIntervalSince1970)")
        
        //initialize file writer
        fileWriter = FileWriter.sharedInstance
        
        // setting the size of the circle and square for iPhone vs. iPad
        if (device == "iPhone") {
            traceView.radius = 400.0  - traceView.gutter
            demoView.radius = 400.0  - demoView.gutter
        } else {
            traceView.radius = 400.0 - traceView.gutter
            demoView.radius = 400.0 - demoView.gutter
        }
        
        resetTime = true
        points.removeAll()
        accelerations.removeAll()
        
        self.nextGameButton.isHidden = true
        
        //display instructions in an alert
        /*
        let alert = UIAlertController(title: "Instructions", message: "Trace the following shapes while listing the months of the year", preferredStyle: UIAlertControllerStyle.alert)
        //let alert = UIAlertController(title: "This time, please list the months of the year repeat as you trace the shapes on the tablet.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil) */
        
        
        // Adonit Stylus
        JotStylusManager.sharedInstance().jotStrokeDelegate = self
        JotStylusManager.sharedInstance().register(self.traceView)
        
        // stylus status view controller (icon in bottom right corner of view)
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
        
        //request audio recording permission
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //its allowed
                    } else {
                        //denied
                    }
                }
                
            }
        } catch {
            //failed to record
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // @IBAction func changeShapeButton(_ sender: AnyObject) {
    func changeShape(){
        traceView.circle = traceView.circle * -1 // switches shape between square (-1) and circle (1)
        traceView.setNeedsDisplay() // update the view
        
        // reset variables
        resetTime = true
        points.removeAll()
        accelerations.removeAll()
        drawView.image = nil
        beganDrawing = false
    }
    
    //Capturing the audio
    func startRecording(){
        let audioFilename = getDocumentsDirectory().appendingPathComponent("traceRecording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            AVaudioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            AVaudioRecorder.delegate = self
            AVaudioRecorder.record()
            
            //display something to tell user recording is happening
        } catch {
            stopRecording()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let getDocumentsDirectory = paths[0]
        return getDocumentsDirectory
    }
    
    func stopRecording(){
        AVaudioRecorder.stop()
        AVaudioRecorder = nil
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool){
        if !flag {
            stopRecording()
        }
    }
    
    @IBAction func submitButton(_ sender: AnyObject)  {
        
        if (points.count > 0) { // make sure there are points to analyze
            
            var results = [Double]()
            
            // calculate total time
            endTime = NSDate().timeIntervalSince1970
            var totalTime = endTime - beginTime
            if beganDrawing == false {
                totalTime = 0.0
            }
            let totalTimeStr = String(format: "%.2f", totalTime)
            
            // calculate metrics
            if (traceView.circle == 1) {
                results = calculateResultsCircle()
            }
            else {
                results = calculateResultsSquare()
                self.nextGameButton.isHidden = false
            }
            
            //Stop Audio Recording
            audioRecorder.stop()
            
            
            
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
            
            results.append(maxX)
            results.append(maxY)
            results.append(maxZ)
            
            // results[0] = average distance from outline
            // results[1] = total distance from outline
            // results[2] = number of times drawing crossed the outline
            // results[3] = max speed in points per second
            // results[4] = first point's distance to outline
            // results[5] = distance between first and last point
            // results[6] = max x acceleration
            // results[7] = max y acceleration
            // results[8] = max z acceleration
            
            // persistence, save the recently calculated results
            self.saveResult(time: totalTime, averageDistance: results[0], totalDistance: results[1], crossedOutline: Int16(results[2]), maxSpeed: results[3], firstDistance: results[4], firstLastDistance: results[5], maxX: results[6], maxY: results[7], maxZ: results[8])
            
            // format strings for output
            let averageStr = String(format: "%.2f", results[0])
            let totalDistStr = String(format: "%.2f", results[1])
            let crossedTotalStr = String(Int(results[2]))
            let maxSpeed = String(format: "%.2f", results[3])
            let firstDistStr = String(format: "%.2f", results[4])
            let firstLastDistStr = String(format: "%.2f", results[5])
            
            // create and present alert of results
            /*
            let alert = UIAlertController(title: "Performance", message: "Total Time: \(totalTimeStr) s\nAverage Distance: \(averageStr) pts\nTotal Distance: \(totalDistStr) pts\nMax Speed: \(maxSpeed) pts/s\nCrossed outline: \(crossedTotalStr) times\nFirst Point Distance: \(firstDistStr) pts\nFirst and Last Point Distance: \(firstLastDistStr) pts\nMax X Accel: \(maxX)\nMax Y Accel: \(maxY)\nMax Z Accel: \(maxZ)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil) */
            
            let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
            shapeImage = renderer.image { ctx in
                drawView.drawHierarchy(in: drawView.bounds, afterScreenUpdates: true)
            }
            UIImageWriteToSavedPhotosAlbum(shapeImage, nil, nil, nil)
            
            
            //gather acceleration data
            //self.findAcceleration()
            
            
            // reset activity
            points.removeAll()
            drawView.image = nil
            beganDrawing = false
            resetTime = true
            accelerations.removeAll()
            
            if(!firstSubmit){
                self.changeShape()
                firstSubmit = true
                
                fileWriter.write(text: "\(Utils.timeOnly()), Total Time: \(totalTimeStr) s\nAverage Distance: \(averageStr) pts\nTotal Distance: \(totalDistStr) pts\nMax Speed: \(maxSpeed) pts/s\nCrossed outline: \(crossedTotalStr) times\nFirst Point Distance: \(firstDistStr) pts\nFirst and Last Point Distance: \(firstLastDistStr) pts\nMax X Accel: \(maxX)\nMax Y Accel: \(maxY)\nMax Z Accel: \(maxZ)")
                fileWriter.write(text: "\(Utils.timeOnly()), FIRST SHAPE END")
                fileWriter.write(text: "\(Utils.timeOnly()), SECOND SHAPE BEGIN")
                
                //let instructionAlert = UIAlertController(title: "Instructions", message: "Once again, repeat the months of the year while you trace the shape", preferredStyle: UIAlertControllerStyle.alert)
                //let alert = UIAlertController(title: "This time, please repeat the following phrase as you trace the shapes in the air: We saw several wild animals", preferredStyle: UIAlertControllerStyle.alert)
                //instructionAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                //self.present(instructionAlert, animated: true, completion: nil)
                
            } else{
                self.navigationController?.popViewController(animated: true)
                
                fileWriter.write(text: "\(Utils.timeOnly()), Total Time: \(totalTimeStr) s\nAverage Distance: \(averageStr) pts\nTotal Distance: \(totalDistStr) pts\nMax Speed: \(maxSpeed) pts/s\nCrossed outline: \(crossedTotalStr) times\nFirst Point Distance: \(firstDistStr) pts\nFirst and Last Point Distance: \(firstLastDistStr) pts\nMax X Accel: \(maxX)\nMax Y Accel: \(maxY)\nMax Z Accel: \(maxZ)")
                fileWriter.write(text: "\(Utils.timeOnly()), SECOND SHAPE END")
                fileWriter.write(text: "\(Utils.timeOnly()), Trace Shape with Speech Game End")
            }
            
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
    
    @IBAction func clearScreenButton(_ sender: AnyObject) {
        drawView.image = nil // remove any points drawn on the screen
        resetTime = true
        beganDrawing = false
        points.removeAll()
    }
    
    // MARK: - Drawing Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* if (demo && !(stylusSettingsView.frame.contains((touches.first?.location(in: view))!))) { // if the demo is showing, the first touch will hide it so the activity can begin
            
            // make sure the stylus is connected before the user can begin drawing
            if !(JotStylusManager.sharedInstance().isStylusConnected) {
                let alert = UIAlertController(title: "Stylus Not Connected", message: "Would you like to connect Adonit Pixel stylus for the activity? Use the stylus icon in the bottom right to help..", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                demo = true
                demoView.removeFromSuperview()
            }
        } else {*/
            if (resetTime) {
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
    //}
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        if !(demo) {
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
        if (!(demo) && !(stylusSettingsView.frame.contains((touches.first?.location(in: view))!)) && !(bufferView.frame.contains((touches.first?.location(in: view))!)) ) {
            
            swiped = true
            let touch = touches.first
            let currentPoint = touch?.location(in: view)
            let currentTime = NSDate().timeIntervalSince1970 - beginTime
            let currentTracePoint = tracePoint(point: (touch?.location(in: view))!, time: currentTime)
            points.append(currentTracePoint)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint!)
            lastPoint = currentPoint!
            print(lastPoint)
            points.append(tracePoint(point: lastPoint, time: NSDate().timeIntervalSince1970))
            fileWriter.write(text: "\(Utils.currentLocalTime()),\(lastPoint.x),\(lastPoint.y)")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (demo) {
            demo = false
            demoView.removeFromSuperview()
        }
        else {
            if !swiped {
                if (!(stylusSettingsView.frame.contains((touches.first?.location(in: view))!)) && !(bufferView.frame.contains((touches.first?.location(in: view))!))) {
                    // draw a single point
                    drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
                    points.append(tracePoint(point: lastPoint, time: NSDate().timeIntervalSince1970 - beginTime))
                }
            }
            
            UIGraphicsBeginImageContext(drawView.frame.size)
            drawView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
            drawView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    // MARK: - Analytics
    
    func calculateResultsCircle() -> [Double] {
        let screenSize: CGRect = UIScreen.main.bounds
        let center = CGPoint(x: (screenSize.width)/2, y: (screenSize.height)/2)
        var distances = [Double]() // stores distance from outline for each point
        var inside = [Bool]() // stores if point was inside or outside of shape
        var radius = Double()
        var results = [Double]() // will hold average distance and total distance
        var maxSpeed = 0.0 // maximum speed between two points
        
        if (device == "iPhone") {
            radius = 168.5
        }
        else {
            radius = 168.5
        }
        
        // calculates the distance from each point to the outline of the circle
        for p in points {
            // distance = distance from center - radius
            let distance = distanceBetween(p1: p.point, p2: center) - radius
            
            if (distance > 0) { // keeps track of if point was inside or outside the circle
                inside.append(false)
            } else {
                inside.append(true)
            }
            
            distances.append(abs(distance))
        }
        
        var sum = distances[0] // total sum of distances
        var insideOut = 0 // how many times the points go over the outline
        
        
        for i in 1...distances.count-1 {
            sum = sum + distances[i]
            if points.count > 1 {
                if (inside[i-1] != inside[i]) {
                    insideOut += 1
                }
                
                // calculating speed: distance between consecutive points divided by time between them
                let distance = distanceBetween(p1: points[i].point, p2: points[i-1].point)
                let time = points[i].time - points[i-1].time
                let speed = distance/time
                if (speed > maxSpeed) {
                    maxSpeed = speed
                }
            }
        }
        let average = sum/Double(distances.count)
        
        // fill the results array
        results.append(average)
        results.append(sum)
        results.append(Double(insideOut))
        results.append(maxSpeed)
        results.append(distances[0])
        results.append(distanceBetween(p1: points[0].point, p2: points[points.count - 1].point))
        
        return results
    }
    
    func calculateResultsSquare() -> [Double] {
        let screenSize: CGRect = UIScreen.main.bounds
        let center = CGPoint(x: (screenSize.width)/2, y: (screenSize.height)/2)
        var distances = [Double]()  // stores distance from outline for each point
        var inside = [Bool]() // stores if point was inside or outside of shape
        var radius = Double()
        var results = [Double]() // will hold average distance and total distance
        var maxSpeed = 0.0 // maximum speed between two points
        
        if (device == "iPhone") {
            radius = 170.0
        }
        else {
            radius = 170.0
        }
        
        // corner points
        let topLeft = CGPoint(x: Double(center.x) - radius, y: Double(center.y) - radius)
        let topRight = CGPoint(x: Double(center.x) + radius, y: Double(center.y) - radius)
        let bottomLeft = CGPoint(x: Double(center.x) - radius, y: Double(center.y) + radius)
        let bottomRight = CGPoint(x: Double(center.x) + radius, y: Double(center.y) + radius)
        
        // calculates the distance from each point to the outline of the square
        for p in points {
            var distance = 0.0
            
            // first check if outside a corner
            if (p.point.x < topLeft.x && p.point.y < topLeft.y) {
                distance = distanceBetween(p1: p.point, p2: topLeft)
            }
            else if (p.point.x > topRight.x && p.point.y < topRight.y) {
                distance = distanceBetween(p1: p.point, p2: topRight)
            }
            else if (p.point.x < bottomLeft.x && p.point.y > bottomLeft.y) {
                distance = distanceBetween(p1: p.point, p2: bottomLeft)
            }
            else if (p.point.x > bottomRight.x && p.point.y > bottomRight.y) {
                distance = distanceBetween(p1: p.point, p2: bottomRight)
            }
            else { // calculate distance from point to each side of the squaure and chose minimum distance
                var distancesLine = [Double]()
                let topDistance = distancePointLine(p: p.point, line1: topLeft, line2: topRight) // top
                let rightDistance = distancePointLine(p: p.point, line1: topRight, line2: bottomRight) // right
                let bottomDistance = distancePointLine(p: p.point, line1: bottomRight, line2: bottomLeft) // bottom
                let leftDistance = distancePointLine(p: p.point, line1: bottomLeft, line2: topLeft) // left
                distancesLine.append(topDistance)
                distancesLine.append(rightDistance)
                distancesLine.append(bottomDistance)
                distancesLine.append(leftDistance)
                distance = distancesLine.min()!
            }
            
            if (p.point.x > topLeft.x && p.point.x < topRight.x && p.point.y > topLeft.y && p.point.y < bottomLeft.y) {
                // checks if point was inside square
                inside.append(true)
            } else {
                inside.append(false)
            }
            
            distances.append(abs(distance))
        }
        
        var sum = distances[0] // total sum of distances
        var insideOut = 0 // keeps track of how many times the points go over the outline
        
        for i in 1...distances.count-1 {
            sum = sum + distances[i]
            if (inside[i-1] != inside[i]) {
                insideOut += 1
            }
            
            // calculating speed: distance between consecutive points divided by time between them
            let distance = distanceBetween(p1: points[i].point, p2: points[i-1].point)
            let time = points[i].time - points[i-1].time
            let speed = distance/time
            if (speed > maxSpeed) {
                maxSpeed = speed
            }
        }
        let average = sum/Double(distances.count)
        
        // fill the results array
        results.append(average)
        results.append(sum)
        results.append(Double(insideOut))
        results.append(maxSpeed)
        results.append(distances[0])
        results.append(distanceBetween(p1: points[0].point, p2: points[points.count - 1].point))
        
        return results
    }
    
    func distanceBetween(p1: CGPoint, p2: CGPoint) -> Double {
        // calculates distance between two points
        let xDist = Double(p1.x - p2.x)
        let yDist = Double(p1.y - p2.y)
        let distance = sqrt((xDist * xDist) + (yDist * yDist))
        return distance
    }
    
    func distancePointLine(p: CGPoint, line1: CGPoint, line2: CGPoint) -> Double {
        // calculates distance from point to line
        let lineDist = sqrt(((line2.y-line1.y)*(line2.y-line1.y))+((line2.x-line1.x)*(line2.x-line1.x)))
        let pointDist = abs(((line2.y-line1.y)*p.x) - ((line2.x - line1.x)*p.y) + (line2.x*line1.y) - (line2.y*line1.x))
        let distance = pointDist/lineDist
        return Double(distance)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? InfoViewController {
            dest.device = self.device // iPhone vs. iPad
            dest.traceResults = traceResults // any results fetched from core data passed
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Core Data
    
    func saveResult(time: Double, averageDistance: Double, totalDistance: Double, crossedOutline: Int16, maxSpeed: Double, firstDistance: Double, firstLastDistance: Double, maxX: Double, maxY: Double, maxZ: Double) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity: TraceResult =  NSEntityDescription.insertNewObject(forEntityName: "TraceResult", into: managedContext) as! TraceResult
        
        entity.date = NSDate()
        entity.time = time
        entity.averageDistance = averageDistance
        entity.totalDistance = totalDistance
        entity.crossedOutline = crossedOutline
        entity.maxSpeed = maxSpeed
        entity.firstDistance = firstDistance
        entity.firstLastDistance = firstLastDistance
        entity.maxXAcceleration = maxX
        entity.maxYAcceleration = maxY
        entity.maxZAcceleration = maxZ
        entity.speech = true
        
        for point in points {
            let newPoint: Point =  NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedContext) as! Point
            newPoint.time = point.time
            newPoint.x = Float(point.point.x)
            newPoint.y = Float(point.point.y)
            newPoint.traceResult = entity
        }
        for acceleration in accelerations {
            let newAccel: StylusAcceleration =  NSEntityDescription.insertNewObject(forEntityName: "StylusAcceleration", into: managedContext) as! StylusAcceleration
            newAccel.time = acceleration.time
            newAccel.x = acceleration.acceleration.x
            newAccel.y = acceleration.acceleration.y
            newAccel.z = acceleration.acceleration.z
            newAccel.traceResult = entity
        }
        for acceleration in self.accelData {
            let newAccel: DeviceAcceleration =  NSEntityDescription.insertNewObject(forEntityName: "DeviceAcceleration", into: managedContext) as! DeviceAcceleration
            newAccel.x = acceleration.x
            newAccel.y = acceleration.y
            newAccel.z = acceleration.z
            newAccel.traceResult = entity
        }
        
        do {
            try managedContext.save()
            //traceResults.append(entity)
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
