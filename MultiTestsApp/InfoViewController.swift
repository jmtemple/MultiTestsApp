//
//  InfoViewController.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 10/18/16.
//  Copyright © 2016 NDMobileCompLab. All rights reserved.
//

import UIKit
import CoreData

class InfoViewController: UIViewController {
    
    var device = "" // set in prepareForSegue() in TraceShapeViewController
    var traceResults : [TraceResult] = []

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var resultTextView: UITextView!
    
    @IBAction func doneButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting font sizes
        if (device == "iPhone") {
            textLabel.font = UIFont(name: "Arial", size: 16.0)
            resultTextView.font = UIFont(name: "Arial", size: 12.0)
            
        } else {
            textLabel.font = UIFont(name: "Arial", size: 24.0)
            resultTextView.font = UIFont(name: "Arial", size: 16.0)
        }
        
        // directions for the activity
        textLabel.text = "Directions: \n\n1. Tap 'Change Shape' to choose between a circle or square.\n\n2. Trace the shape in the center.\n\n3. Once done tracing, tap 'Submit'.\n\n4. If at any time you would like to start over, tap 'Clear Screen'."
        
        // lists all the previous results fetched from core data
        var resultLabelText = ""
        
        for result in traceResults {
            // formatting all the strings
            let totalTimeStr = String(format: "%.2f", result.time)
            let averageStr = String(format: "%.2f", result.averageDistance)
            let totalDistStr = String(format: "%.2f", result.totalDistance)
            let crossedTotalStr = String(result.crossedOutline)
            let maxSpeed = String(format: "%.2f", result.maxSpeed)
            let firstDistStr = String(format: "%.2f", result.firstDistance)
            let firstLastDistStr = String(format: "%.2f", result.firstLastDistance)
            let maxXStr = String(format: "%.2f", result.maxXAcceleration)
            let maxYStr = String(format: "%.2f", result.maxYAcceleration)
            let maxZStr = String(format: "%.2f", result.maxZAcceleration)
            
            resultLabelText.append("Total Time: \(totalTimeStr) s, Average Distance: \(averageStr) pts, Total Distance: \(totalDistStr) pts, \nMax Speed: \(maxSpeed) pts/s, Crossed outline: \(crossedTotalStr) times, \nFirst Point Distance: \(firstDistStr) pts, First and Last Point Distance: \(firstLastDistStr) pts\nMax X Accel: \(maxXStr), Max Y Accel: \(maxYStr), Max Z Accel: \(maxZStr), Total Points: \((result.point?.count)!), Total Acceleration Points: \((result.stylusAcceleration?.count)!)\n\n")
        }
        
        resultTextView.text = resultLabelText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
