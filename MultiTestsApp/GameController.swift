//
//  GameController.swift
//  MultiTestsApp
//
//  Created by mikel kota
//  Copyright © 2016 NDMobileCompLab. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIImage
import UIKit.UICollectionViewCell
import CoreData

//Calls function from the MemoryGame class. 
class GameController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MemoryGameDelegate {

    //Controlls the 
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextGameButton: UIButton!
    
    // persistence
    let defaults = UserDefaults.standard
    var memoryResults = [MemoryResult]()
    
    //initials from consent vc
    var initialsText = ""
    
    //file writer
    fileprivate var fileWriter: FileWriter!
    
    //game type colorshape / card
    var gameType = ""
    
    //iPad acceleration vars
    let manager = CMMotionManager()
    var accelData = [CMAcceleration]()
    
    var gameController : MemoryGame!
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameController = MemoryGame(type: gameType)
        gameController.delegate = self
        resetGame()
        timerLabel.isHidden = true
        nextGameButton.isHidden = true
        
        let fileName = "\(initialsText)"
        
        fileWriter = FileWriter.sharedInstance
        fileWriter.setFileName(name: fileName)
        
        fileWriter.write(text: "\(Utils.timeOnly()), Memory Game Begins \(gameType)")

        
        let alert = UIAlertController(title: "Instructions", message: "Find the matching tiles in as few taps as possible", preferredStyle: UIAlertControllerStyle.alert)
        //let alert = UIAlertController(title: "This time, please repeat the following phrase as you trace the shapes in the air: We saw several wild animals", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        //start recording acceleration
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if gameController.isPlaying { resetGame() }
    }
    
    @IBAction func didPressPlayButton(_ sender: AnyObject) {
        if gameController.isPlaying {
            resetGame()
            playButton.setTitle(NSLocalizedString("PLAY", comment: "play"), for: UIControlState())
        } else {
            setupNewGame()
            playButton.setTitle(NSLocalizedString("RESET", comment: "stop"), for: UIControlState())
        }
    }
    
    func resetGame() {
        gameController.stopGame()
        //Reset timer.
        if timer?.isValid == true {
            timer?.invalidate()
            timer = nil
        }
        //Screen set to default. 
        collectionView.isUserInteractionEnabled = false
        collectionView.reloadData()
        timerLabel.text = "Time: 00:00"

        playButton.setTitle(NSLocalizedString("PLAY", comment: "play"), for: UIControlState())
    }
    
    func setupNewGame() {
        let cardsData:[UIImage]!
        if (self.gameType == "colorshape"){
            cardsData = MemoryGame.cardImages
            gameController.newGame(cardsData)
        }else if (self.gameType == "card"){
            cardsData = MemoryGame.secondCardImages
            gameController.newGame(cardsData)
        }
        
    }
    
    func gameTimerAction() {

        timerLabel.text = String(format: "Time: %.0f s", NSLocalizedString("TIME", comment: "time"), gameController.elapsedTime)
        timerLabel.text = String(format: "Time: %.0fs", NSLocalizedString("TIME", comment: "time"), gameController.elapsedTime)
    }
    
    //func saveScore(...) 
    
    //Set up view.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //12 cards
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameController.numberOfCards > 0 ? gameController.numberOfCards : 12
    }
    
    //cell will identify the spot for a card. 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath) as! CardCVC
        //showCard function shows the cards on the screen. CardCVC-Card collection view controller decides what to show with the cards. The input false means to show or not show, its set false. And animated: false, it is not animated because of false so the back of the cards show. Follow up on CardCVC for methods.
        cell.showCard(false, animated: false)
        guard let card = gameController.cardAtIndex((indexPath as NSIndexPath).item) else {return cell}
        cell.card = card
        return cell
    }
    
    //Delegate method didSelectItemAtIndexPath.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //The index path for the cards, is from CardCVC.
        let cell = collectionView.cellForItem(at: indexPath) as! CardCVC
        if cell.shown {return}
        //If user selects a card in a cell. The card is traced by cell.card.
        gameController.didSelectCard(cell.card)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    //Layout for cards.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth: CGFloat = collectionView.frame.width / 3.0-15.0
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    //Protocol function.
    func memoryGameDidStart(_ game: MemoryGame) {
        collectionView.reloadData()
        nextGameButton.isHidden = true
        collectionView.isUserInteractionEnabled = true
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameController.gameTimerAction), userInfo: nil, repeats: true)
    }
    
    //Protocol function.
    func memoryGame(_ game: MemoryGame, hideCards cards: [Card]) {
        for card in cards {
            guard let index = gameController.indexForCard(card) else { continue }
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section:0)) as! CardCVC
            cell.showCard(false, animated: true)
        }
    }
    
    //Protocol function.
    func memoryGame(_ game: MemoryGame, showCards cards: [Card]) {
        for card in cards {
            guard let index = gameController.indexForCard(card) else { continue }
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section:0)) as! CardCVC
            cell.showCard(true, animated: true)
        }
    }
    
    //Protocol function.
    func memoryGameDidEnd(_ game: MemoryGame, elapsedTime: TimeInterval) {
        timer?.invalidate()
        let elapsedTime = gameController.elapsedTime
        fileWriter.write(text: "\(Utils.timeOnly()),\(elapsedTime)")
        let alertController = UIAlertController(title: NSLocalizedString("YOU WIN!",  comment: "title"), message: String(format: "%@ %.0f seconds", NSLocalizedString("You finished the game in", comment: "message"), elapsedTime), preferredStyle: .alert)
        let saveScoreAction = UIAlertAction(title: NSLocalizedString("OK", comment: "save score"), style: .default) { [weak self] (_) in
            //let nameTextField = alertController.textFields![0] as UITextField
            //guard let name = nameTextField.text else { return }
            //self?.savePlayerScore(name, score: elapsedTime)
            self?.resetGame()
        }
        //saveScoreAction.isEnabled = false
        //saveScoreAction.isEnabled = true
        alertController.addAction(saveScoreAction)
        /*alertController.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Your name", comment: "your name")
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange,
                                                   object: textField,
                                                   queue: OperationQueue.main) { (notification) in
                                                    saveScoreAction.isEnabled = textField.text != ""
            }
        }*/
        
        /*
        let cancelAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: "dismiss"), style: .cancel) { [weak self] (action) in
            self?.resetGame()
        }
        alertController.addAction(cancelAction)
         */
        self.saveData(elapsedTime: elapsedTime)
        self.findAcceleration()
        self.nextGameButton.isHidden = false
        self.playButton.isHidden = true
        
        self.present(alertController, animated: true) { }
    }
    
    func saveData(elapsedTime: TimeInterval){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
         let managedContext = appDelegate.managedObjectContext
        
        
        let entity: MemoryResult =  NSEntityDescription.insertNewObject(forEntityName: "MemoryResult", into: managedContext) as! MemoryResult
        
        entity.elapsedTime = elapsedTime
        
        for acceleration in self.accelData {
            let newAccel: DeviceAcceleration =  NSEntityDescription.insertNewObject(forEntityName: "DeviceAcceleration", into: managedContext) as! DeviceAcceleration
            newAccel.x = acceleration.x
            newAccel.y = acceleration.y
            newAccel.z = acceleration.z
            newAccel.memoryResult = entity
        }
        
        do {
            try managedContext.save()
            memoryResults.append(entity)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
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
    
    @IBAction func nextGameButton(_ sender: Any) {
        //self.performSegue(withIdentifier: "toConnectDots", sender: self.parent)
    
        self.navigationController?.popViewController(animated: true)
       
        fileWriter.write(text: "\(Utils.timeOnly()), Memory Game End \(gameType)")
        
    }
}
