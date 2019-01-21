//
//  TargetGameViewController.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 2/6/18.
//  Copyright © 2018 NDMobileCompLab. All rights reserved.
//

import Foundation
import UIKit

class TargetGameViewController: UIViewController {
    
    //initials from consent vc
    var initialsText = ""
    
    //file writer
    var fileWriter: FileWriter!
	
	@IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var instructLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
	var countdown = Timer()
	var countDownCount: Int = 30
	var lastPos: Int = 6
    
	var largeCircle = UIButton()
	var smallCircle = UIButton()
	
	var playing: Bool = false
	var tapCounter: Int = 0
	var largeCircleTapCounter: Int = 0
	var smallCircleTapCounter: Int = 0
    
	
    @IBOutlet weak var submitButton: UIButton!
    override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
        self.smallCircle.isHidden = true
        self.largeCircle.isHidden = true
        self.submitButton.isHidden = true
        
        let fileName = "\(initialsText)"
        
        fileWriter = FileWriter.sharedInstance
        fileWriter.setFileName(name: fileName)
        
        fileWriter.write(text: "\(Utils.timeOnly()), Target Game Begins")

		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func newTarget() {
		
		let radius:CGFloat = 100
		let iradius = Int(radius)
		let posX = Int(UIScreen.main.bounds.width/2 - radius)
        let posY = Int(UIScreen.main.bounds.height/2 - radius)
		
		var pos = Int(arc4random()%4)
		while (pos == self.lastPos){
			pos = Int(arc4random()%4)               //we want the position to change, so we keep track of the last position and put the next one somewhere else
		}
		self.lastPos = pos
		
		var x = Int(arc4random())%posX
        var y = Int(arc4random())%posY
        
		
		switch pos{
        case 0:
            print("debug case 0, x: \(x), y: \(y)")
            if y < 100{
                y = y + 100
                print("case 0, y is samll, add 50 to y, new y \(y)")
            }
            break
        case 1:
            print("debug case 1, x: \(x), y: \(y)")
            if y < 100{
                y = y + 100
                print("case 1, y is samll, add 50 to y, new y \(y)")
            }
            x = x + Int(UIScreen.main.bounds.width/2)
		case 2:
			y = y + Int(UIScreen.main.bounds.height/2)
		case 3:
			x = x + Int(UIScreen.main.bounds.width/2)
			y = y + Int(UIScreen.main.bounds.height/2) 
            
		default:
			self.endGame()
		}
		
		print("X: \(x) Y: \(y)")
		fileWriter.write(text: "\(Utils.timeOnly()), X: \(x) Y: \(y)")
        
		largeCircle.frame = CGRect(x: x, y: y, width: iradius, height: iradius)
		largeCircle.layer.cornerRadius = radius/2
		largeCircle.layer.backgroundColor = UIColor.black.cgColor
		largeCircle.addTarget(self, action: #selector(largeCircleTapped), for: .touchDown)
		
		smallCircle.frame = CGRect(x: x + iradius/4, y: y + iradius/4, width: iradius/2, height: iradius/2)
		smallCircle.layer.cornerRadius = radius/4
		smallCircle.layer.backgroundColor = UIColor.red.cgColor
		smallCircle.addTarget(self, action: #selector(smallCircleTapped), for: .touchDown)
		
		self.view.addSubview(largeCircle)
		self.view.addSubview(smallCircle)
		
	}
	
	func largeCircleTapped(){
		print("large circle tapped")
        fileWriter.write(text: "\(Utils.timeOnly()), Large Circle Tapped")
		self.largeCircle.removeFromSuperview()
		self.smallCircle.removeFromSuperview()
		self.largeCircleTapCounter += 1
		self.newTarget()
	}
	
	func smallCircleTapped(){
		print("small circle tapped")
        fileWriter.write(text: "\(Utils.timeOnly()), Small Circle Tapped")
		self.largeCircle.removeFromSuperview()
		self.smallCircle.removeFromSuperview()
		self.smallCircleTapCounter += 1
		self.newTarget()
	}
	
	func endGame(){
		self.playing = false
		countdown.invalidate()
		self.largeCircle.isUserInteractionEnabled = false
		self.smallCircle.isUserInteractionEnabled = false
        
        self.submitButton.isHidden = false
        self.smallCircle.isHidden = true
        self.largeCircle.isHidden = true
        fileWriter.write(text: "Total Small Circles Tapped: \(smallCircleTapCounter), Total Large Circles Tapped: \(largeCircleTapCounter), Total Circles Tapped: \(smallCircleTapCounter + largeCircleTapCounter)")
        
	}
	
	func countDown(){ //this function updates the countdown every 1 seconds
		self.countDownCount = self.countDownCount - 1
		
		//if the countdown is 0 - the game is over
		if(self.countDownCount < 0){
			self.countDownLabel.text = "0"
			self.endGame()
			return
		}
		self.countDownLabel.text = String(format: "%d", self.countDownCount)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if(self.playing){
			print("user tapped")
			tapCounter += 1
		}
	}
	
    
    @IBAction func startGameAction(_ sender: Any) {
        self.instructLabel.isHidden = true
        self.startButton.isHidden = true
        self.smallCircle.isHidden = false
        self.largeCircle.isHidden = false
        
        self.countdown = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        self.playing = true
        self.newTarget()

    }
    
    @IBAction func submitAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        fileWriter.write(text: "\(Utils.timeOnly()), Target Game End")

    }
}
