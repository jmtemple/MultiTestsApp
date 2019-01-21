//
//  GameViewController.swift
//  phystut
//
//  Created by Collin Klenke on 3/20/17.
//  Copyright © 2017 Collin Klenke. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    //initials from consent vc
    var initialsText = ""

    //file writer
    var fileWriter: FileWriter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let alert = UIAlertController(title: "Instructions", message: "Tap once to make the ball fall. Tap again to stop it in the target. Land as many in the target as you can", preferredStyle: UIAlertControllerStyle.alert)
        //alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        //self.present(alert, animated: true, completion: nil)
        
        let fileName = "\(initialsText)"
        
        fileWriter = FileWriter.sharedInstance
        fileWriter.setFileName(name: fileName)
        
        fileWriter.write(text: "\(Utils.timeOnly()), Falling Ball Game Begins")

        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                //scene.viewController = self
                // Present the scene
                view.presentScene(scene)
                scene.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
