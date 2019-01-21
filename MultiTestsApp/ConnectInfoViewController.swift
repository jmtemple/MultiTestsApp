//
//  ConnectInfoViewController.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 4/4/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import UIKit
import CoreData

class ConnectInfoViewController: UIViewController {
    
    @IBOutlet weak var resultTextView: UITextView!
    var device = ""
    var connectResults : [ConnectResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // lists all the previous results fetched from core data
        var resultLabelText = ""
        
        for result in connectResults {
            // formatting all the strings
            let totalTimeStr = String(format: "%.2f", result.time)
            let maxXStr = String(format: "%.2f", result.maxXAcceleration)
            let maxYStr = String(format: "%.2f", result.maxYAcceleration)
            let maxZStr = String(format: "%.2f", result.maxZAcceleration)
            
            resultLabelText.append("Total Time: \(totalTimeStr) s, Max X Accel: \(maxXStr), Max Y Accel: \(maxYStr), Max Z Accel: \(maxZStr), Total Points: \((result.point?.count)!), Total Acceleration Points: \((result.stylusAcceleration?.count)!)\n\n")
        }
        
        resultTextView.text = resultLabelText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
