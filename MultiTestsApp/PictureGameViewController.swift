//
//  PictureGameViewController.swift
//  MultiTestsApp
//
//  Created by John Templeton on 6/8/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//


import UIKit
import Speech
import GameKit
import CoreData
import CoreMotion

//this is to shuffle the index array we make
extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if(i != j){
                self.swapAt(i, j)
            }
        }
    }
}


class PictureGameViewController: UIViewController, SFSpeechRecognizerDelegate, UITextFieldDelegate {
    
    //storyboard elements
    @IBOutlet weak var topleft: UIImageView!
    @IBOutlet weak var topright: UIImageView!
    @IBOutlet weak var center: UIImageView!
    @IBOutlet weak var bottomleft: UIImageView!
    @IBOutlet weak var bottomright: UIImageView!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var BeginButton: UIButton!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var topRightLabel: UILabel!
    @IBOutlet weak var topLeftLabel: UILabel!
    @IBOutlet weak var bottomRightLabel: UILabel!
    @IBOutlet weak var bottomLeftLabel: UILabel!
    @IBOutlet weak var instructLabel: UILabel!
    //@IBOutlet weak var initialsTextField: UITextField!
    
    //initials from consent vc
    var initialsText = ""
    
    
    //timing variables - used to set timers
    var timer = Timer()
    var countdown = Timer()
    var hideTimer = Timer()
    var countDownCount: Int = 0
    var playerCanGuess: Bool = true
    
    // persistence
    let defaults = UserDefaults.standard
    //var pictureResults = [PictureResult]()
    
    //this is the array of images - to add more simply add a comma and copy the format of the one above
    //then drag the image with xxx.png name into the Assets.xcassets folder in the project navigator on the left
    var images: [UIImage] = [
        UIImage(named: "banana")!,
        UIImage(named: "calculator")!,
        UIImage(named: "diamond")!,
        UIImage(named: "elephant")!,
        UIImage(named: "flamingo")!,
        UIImage(named: "giraffe")!,
        UIImage(named: "kangaroo")!,
        UIImage(named: "octopus")!,
        UIImage(named: "piano")!,
        UIImage(named: "pineapple")!,
        UIImage(named: "skeleton")!,
        UIImage(named: "strawberry")!,
        UIImage(named: "tomato")!,
        UIImage(named: "tricycle")!,
        UIImage(named: "umbrella")!,
        UIImage(named: "watermelon")!
    ]
    
    //2D array of strings - each row is for a different image
    var imageStrings: [[String]] = [
        ["banana"],
        ["calculator"],                 //important to keep these lowercase
        ["diamond"],
        ["elephant"],
        ["flamingo"],
        ["giraffe"],
        ["kangaroo"],
        ["octopus"],
        ["piano"],
        ["pineapple"],
        ["skeleton"],
        ["strawberry"],
        ["tomato"],
        ["tricycle"],
        ["umbrella"],
        ["watermelon"]
    ]
    
    var stringToGuess: [String] = []
    
    //create an array to pick which image is next
    var arrayIndex: [Int] = Array(0...15) //change 15 to n-1 for n pictures
    var correct: Int = 0
    var incorrect: Int = 0
    var totalIncorrect: Int = 0
    var lastPos: Int = 6
    var consecutiveIncorrect: Int = 0
    
    
    //vars used for recording and recognizing speech
    var audioEngine = AVAudioEngine()
    var speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    var request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var spokenWordsArray = [[String]]()
    var tempSpokenArray = [String]()
    
    //vars to record acceleration in iPad
    let manager = CMMotionManager()
    var accelData = [CMAcceleration]()
    
    
    //audio recorder
    var audioRecorder: MyAudioRecorder!
    
    //file writer
    var fileWriter: FileWriter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeGame()
        
        //initialize the recorder, singletone instance
        audioRecorder = MyAudioRecorder.sharedInstance
        
        //initialize file writer
        fileWriter = FileWriter.sharedInstance
        
        
        //record acceleration data
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
        
        self.hideKeyboardWhenTappedAround()
        //self.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        presentingViewController?.navigationItem.title = "Picture Test"
    }
    
    func initializeGame(){
        ////add ---- Afzal ------
        
        //title
        //navigationController?.navigationBar.topItem?.title = "Picture Test"
        
        
        
        timer = Timer()
        countdown = Timer()
        hideTimer = Timer()
        countDownCount = 50
        playerCanGuess = true
        
        stringToGuess = []
        
        arrayIndex = Array(0...15) //change 15 to n-1 for n pictures
        correct = 0
        incorrect = 0
        totalIncorrect = 0
        lastPos = 6
        consecutiveIncorrect = 0
        
        audioEngine = AVAudioEngine()
        speechRecognizer = SFSpeechRecognizer()
        request = SFSpeechAudioBufferRecognitionRequest()
        spokenWordsArray = [[String]]()
        tempSpokenArray = [String]()
        
        
        self.BeginButton.isHidden = false
        self.introLabel.isHidden = false
        self.instructLabel.isHidden = false
        //self.initialsTextField.isHidden = false
        ////end
        
        self.hideImages()
        self.arrayIndex.shuffle()
        self.requestSpeechAuthorization()
        //self.center.center = self.view.center
        self.BeginButton.center.x = self.view.center.x
        self.countDownLabel.isHidden = true
        self.introLabel.adjustsFontSizeToFitWidth = true
        self.finishButton.isHidden = true
        
        //let alert = UIAlertController(title: "Instructions", message: "Say the word which best corresponds to the picutre and letter provided", preferredStyle: UIAlertControllerStyle.alert)
        //alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        //self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func beginButtonPressed(_ sender: UIButton){
        
        /*let initials:String = initialsText
        
        /*if initials.isEmpty{
            return
        }*/*/
        //let fileName = "\(initials)_\(simpleFormattedDateTime(date: Date()))"
        let fileName = "\(initialsText)"
        fileWriter.setFileName(name: fileName)
        
        fileWriter.write(text: "\(Utils.timeOnly()), Picture Game Begins")
        print("Picture Game")
        print("start button pressed...")
        
        
        self.BeginButton.isHidden = true
        self.introLabel.isHidden = true
        self.instructLabel.isHidden = true
        //self.initialsTextField.isHidden = true
        //self.introLabel.text = String(format: "%d", self.countDownCount)
        self.countdown = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        self.recordAndRecognizeSpeech()
        self.generateImage()
        
        audioRecorder.startRecording(fileName: "\(fileName)_picture_\(Date().timeIntervalSince1970)")
        
        
    }
    
    //THIS METHOD HERE DEMONSTRATES HOW TO GATHER SAVED RESULTS
    @IBAction func finishButtonPressed(_ sender: Any) {
        
        /*let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let managedContext = appDelegate.managedObjectContext
         
         
         var signatureResults = [SignatureResult]()
         var traceResults = [TraceResult]()
         var motorResults = [MotorResult]()
         var memoryResults = [MemoryResult]()
         var connectResults = [ConnectResult]()
         var fallingBallResults = [FallingBallResult]()
         var visResults = [VisResult]()
         var colorResults = [ColorResult]()
         var pictureResults = [PictureResult]()
         
         //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
         
         let signatureFetchRequest:NSFetchRequest<SignatureResult> = SignatureResult.fetchRequest()
         do {
         let signatureFetchResults = try managedContext.fetch(signatureFetchRequest)
         signatureResults = signatureFetchResults
         } catch let error as NSError {
         print("Could not fetch \(error), \(error.userInfo)")
         }
         
         var i = signatureResults.count - 1
         let signResultString = "Singature results:\nMax X accel: \(signatureResults[i].maxXAcceleration)\nMax Y accel: \(signatureResults[i].maxYAcceleration) \nMax Z accel: \(signatureResults[i].maxZAcceleration)"
         
         //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
         
         let traceFetchRequest:NSFetchRequest<TraceResult> = TraceResult.fetchRequest()
         do {
         let traceFetchResults = try managedContext.fetch(traceFetchRequest)
         traceResults = traceFetchResults
         } catch let error as NSError {
         print("Could not fetch \(error), \(error.userInfo)")
         }
         
         //USE TRACE RESULTS TWICE BECAUSE ONE HAS SPEECH ATTACHED, WITH THE BOOL VAL speech SET TO TRUE FOR SPEECH
         
         i = traceResults.count - 2
         let traceResultString = "Trace results:\nCrosses: \(traceResults[i].crossedOutline)\nAverage Distance: \(traceResults[i].averageDistance)\nFirst Distance: \(traceResults[i].firstDistance)\nFirst Last Distance: \(traceResults[i].firstLastDistance)\nMax Speed: \(traceResults[i].maxSpeed)\nMax X Accel: \(traceResults[i].maxXAcceleration)\nMax Y Accel: \(traceResults[i].maxYAcceleration)\nMax Z Accel: \(traceResults[i].maxZAcceleration)\nTime: \(traceResults[i].time)\nTotal Distance: \(traceResults[i].totalDistance)"
         
         i = traceResults.count - 1
         let traceSpeechResultString = "Trace Speech results:\nCrosses: \(traceResults[i].crossedOutline)\nAverage Distance: \(traceResults[i].averageDistance)\nFirst Distance: \(traceResults[i].firstDistance)\nFirst Last Distance: \(traceResults[i].firstLastDistance)\nMax Speed: \(traceResults[i].maxSpeed)\nMax X Accel: \(traceResults[i].maxXAcceleration)\nMax Y Accel: \(traceResults[i].maxYAcceleration)\nMax Z Accel: \(traceResults[i].maxZAcceleration)\nTime: \(traceResults[i].time)\nTotal Distance: \(traceResults[i].totalDistance)"
         
         //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
         
         let motorFetchRequest:NSFetchRequest<MotorResult> = MotorResult.fetchRequest()
         do {
         let motorFetchResults = try managedContext.fetch(motorFetchRequest)
         motorResults = motorFetchResults
         } catch let error as NSError {
         print("Could not fetch \(error), \(error.userInfo)")
         }
         
         //not much info about the motor game/motor game with speech to display in the alert
         
         //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
         
         let memoryFetchRequest:NSFetchRequest<MemoryResult> = MemoryResult.fetchRequest()
         do {
         let memoryFetchResults = try managedContext.fetch(memoryFetchRequest)
         memoryResults = memoryFetchResults
         } catch let error as NSError {
         print("Could not fetch \(error), \(error.userInfo)")
         }
         
         i = memoryResults.count - 1
         let memoryResultString = "Memory results: \nElapsed time: \(memoryResults[i].elapsedTime)"
         
         //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
         
         let connectFetchRequest:NSFetchRequest<ConnectResult> = ConnectResult.fetchRequest()
         do {
         let connectFetchResults = try managedContext.fetch(connectFetchRequest)
         connectResults = connectFetchResults
         } catch let error as NSError {
         print("Could not fetch \(error), \(error.userInfo)")
         }
         
         //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
         
         let fallingBallFetchRequest:NSFetchRequest<FallingBallResult> = FallingBallResult.fetchRequest()
         do {
         let fallingBallFetchResults = try managedContext.fetch(fallingBallFetchRequest)
         fallingBallResults = fallingBallFetchResults
         } catch let error as NSError {
         print("Could not fetch \(error), \(error.userInfo)")
         }
         
         //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
         
         let visFetchRequest:NSFetchRequest<VisResult> = VisResult.fetchRequest()
         do {
         let visFetchResults = try managedContext.fetch(visFetchRequest)
         visResults = visFetchResults
         } catch let error as NSError {
         print("Could not fetch \(error), \(error.userInfo)")
         }
         
         //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
         
         let colorFetchRequest:NSFetchRequest<ColorResult> = ColorResult.fetchRequest()
         do {
         let colorFetchResults = try managedContext.fetch(colorFetchRequest)
         colorResults = colorFetchResults
         } catch let error as NSError {
         print("Could not fetch \(error), \(error.userInfo)")
         }
         var colorResultString = "No Color Results"
         if (colorResults.count > 0){
         i = colorResults.count - 1
         colorResultString = "Color game results:\nCorrect: \(colorResults[i].correct)\nIncorrect: \(colorResults[i].incorrect)"
         }
         
         //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
         
         
         let pictureFetchRequest:NSFetchRequest<PictureResult> = PictureResult.fetchRequest()
         do {
         let pictureFetchResults = try managedContext.fetch(pictureFetchRequest)
         pictureResults = pictureFetchResults
         } catch let error as NSError {
         print("Could not fetch \(error), \(error.userInfo)")
         }
         
         var pictureResultString = "No Picture Results"
         if(pictureResults.count > 0){
         i = pictureResults.count - 1
         pictureResultString = "Picture game results:\nCorrect: \(pictureResults[i].correct)\nIncorrect: \(pictureResults[i].incorrect)"
         }
         
         //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
         
         let resultAlert = UIAlertController(title: "Results", message: "\(signResultString)\n\(traceResultString)\n\(traceSpeechResultString)\n\(memoryResultString)\n\(colorResultString)\n\(pictureResultString)", preferredStyle: UIAlertControllerStyle.alert)
         //let alert = UIAlertController(title: "This time, please repeat the following phrase as you trace the shapes in the air: We saw several wild animals", preferredStyle: UIAlertControllerStyle.alert)
         resultAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
         self.present(resultAlert, animated: true, completion: nil)
         */
    }
    
    @objc func countDown(){ //this function updates the countdown every .1 seconds
        self.countDownCount = self.countDownCount - 1
        //if the countdown is 0 - the game is over
        if(self.countDownCount < 0){
            self.introLabel.text = "0"
            print("count down timer becomes 0, so end game")
            self.endGame()
            return
        }
        //self.introLabel.text = String(format: "%d", self.countDownCount)
    }
    
    func simpleFormattedDateTime(date:Date)-> String{
        let dateFormatter:DateFormatter? = DateFormatter()
        dateFormatter!.dateFormat = "MM_dd_yy_HH_mm_ss"
        if let currentTime = dateFormatter!.string(from: date) as String?{
            return currentTime
        } else{
            return ""
        }
    }
    
    //permissions for using the microphone
    func requestSpeechAuthorization(){
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus{
                case .authorized:
                    self.introLabel.text = "Press Start to Begin"
                    self.BeginButton.isEnabled = true
                case .denied:
                    self.BeginButton.isEnabled = false
                    self.introLabel.text = "User denied access to speech recognition"
                case .restricted:
                    self.BeginButton.isEnabled = false
                    self.introLabel.text = "Speech recognition is restricted on this device"
                case .notDetermined:
                    self.BeginButton.isEnabled = false
                    self.introLabel.text = "Speech recognition not yet authorized"
                }
            }
            
        }
    }
    
    //clears the image off the screen no matter what position it is in
    func hideImages(){
        self.topright.isHidden = true
        self.topleft.isHidden = true
        //self.center.isHidden = true
        self.bottomleft.isHidden = true
        self.bottomright.isHidden = true
        self.topRightLabel.isHidden = true
        self.topLeftLabel.isHidden = true
        self.bottomRightLabel.isHidden = true
        self.bottomLeftLabel.isHidden = true
        //playerCanGuess = true
    }
    
    @objc func generateImage(){
        
        if self.countDownCount <= 1{
            return
        }
        
        if(self.arrayIndex.isEmpty){ //avoid issues with not having another image to display, the game should be over
            print("generate image array index empty, end game..")
            self.endGame()
            return
        }
        
        self.tempSpokenArray.removeAll()
        
        let i = Int(self.arrayIndex.removeFirst())
        var pos = Int(arc4random()%4)
        while (pos == self.lastPos){
            pos = Int(arc4random()%4)               //we want the position to change, so we keep track of the last position and put the next one somewhere else
        }
        self.lastPos = pos
        
        self.stringToGuess = self.imageStrings[i]
        fileWriter.write(text: "\(Utils.timeOnly()),generate_new_image,\(stringToGuess[0])")
        
        
        switch pos{
        case 0:
            self.topleft.contentMode = .scaleAspectFit
            self.topleft.clipsToBounds = true
            self.topleft.image = self.images[i]
            self.topleft.isHidden = false
        case 1:
            self.topright.contentMode = .scaleAspectFit
            self.topright.clipsToBounds = true
            self.topright.image = self.images[i]
            self.topright.isHidden = false
            //case 2:
            //self.center.image = self.images[i]
        //self.center.isHidden = false
        case 2:
            self.bottomleft.contentMode = .scaleAspectFit
            self.bottomleft.clipsToBounds = true
            self.bottomleft.image = self.images[i]
            self.bottomleft.isHidden = false
        case 3:
            self.bottomright.contentMode = .scaleAspectFit
            self.bottomright.clipsToBounds = true
            self.bottomright.image = self.images[i]
            self.bottomright.isHidden = false
        default:
            self.hideImages()
            print("generate image switch default, so end game")
            self.endGame()
        }
        
        playerCanGuess = true
        //set timer to hide the image after 1 second
        //now we are setting it to add the letter after 5 seconds, take away the image after 20
        if self.hideTimer.isValid{
            self.hideTimer.invalidate()
        }
        self.hideTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(endOfTimer), userInfo: nil, repeats: false)
        
    }
    
    /*@objc func addLetter(){
     //pictures position is known in lastpos
     //letter to add is known in the first char in stringToGuess
     print("adding letter hint")
     if self.hideTimer.isValid{
     self.hideTimer.invalidate()
     }
     self.hideTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(endOfTimer), userInfo: nil, repeats: false)
     
     
     
     //USE FOR LOOP? BREAK AFTER 1
     
     //guard let index = self.stringToGuess.characters.index(self.stringToGuess.startIndex, offsetBy) else{
     //print("error getting first char")
     //return
     //}
     //print("first char: \(firstChar.uppercased())")
     let c = String(self.stringToGuess[0].first!)
     switch self.lastPos {
     case 0:
     self.topLeftLabel.text = c.uppercased()
     self.topLeftLabel.isHidden = false
     case 1:
     self.topRightLabel.text = c.uppercased()
     self.topRightLabel.isHidden = false
     case 2:
     self.bottomLeftLabel.text = c.uppercased()
     self.bottomLeftLabel.isHidden = false
     case 3:
     self.bottomRightLabel.text = c.uppercased()
     self.bottomRightLabel.isHidden = false
     default:
     return
     }
     
     } */
    
    @objc func endOfTimer(){
        //the last 10 seconds end, user did not guess the correct word, we remove this word and go on to the next
        print("user failed to guess the word, presenting new picture...")
        
        //record all words spoken during this interval
        self.spokenWordsArray.append(self.tempSpokenArray)
        
        
        self.totalIncorrect += 1
        //self.incorrect += 1
        self.consecutiveIncorrect += 1
        if self.consecutiveIncorrect >= 5 || self.totalIncorrect >= 10{
            self.hideImages()
            print("incorrect word limit, so end game")
            self.endGame()
            return
        }
        
        self.hideImages()
        self.generateImage()
        
    }
    
    //if they miss 5 in a row, abort
    //if they miss a total of 10, abort
    //make an array of strings for everything they say during each image shown
    //also go through and find what third party frameworks each game uses
    
    func checkWord(spokenWord: String){
        
        //potentially filter the words here, return if its not part of a group of strings or something
        self.tempSpokenArray.append(spokenWord)
        
        var cor = 0
        for word in self.stringToGuess {
            if spokenWord == word{          //go through each word it could be and check if it is right
                self.correct += 1
                cor = 1
                break
            }
        }
        if(cor == 0){
            self.incorrect += 1
            //self.consecutiveIncorrect += 1
        }
        //self.hideImages()
        
        if(cor == 1){
            self.consecutiveIncorrect = 0
            self.playerCanGuess = false
            self.hideImages()
            self.hideTimer.invalidate()
            self.hideTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(generateImage), userInfo: nil, repeats: false)
            
            //add all words spoken during this interval to spoken array
            self.spokenWordsArray.append(self.tempSpokenArray)
            fileWriter.write(text: "\(Utils.timeOnly()),\(stringToGuess[0]),correct,\(spokenWord)")
            //fileWriter.write(text: "\(stringToGuess)... correct... \(spokenWord)")
        }else{
            print("word to say: \(self.stringToGuess[0]) word guessed: \(spokenWord) correct: \(self.correct) incorrect: \(self.incorrect)")
            fileWriter.write(text: "\(Utils.timeOnly()),\(stringToGuess[0]),incorrect,\(spokenWord)")
        }
        
        
    }
    
    //clear everything and display results
    func endGame(){
        
        fileWriter.write(text: "\(Utils.timeOnly()),Picture Game End")
        request.endAudio()
        
        audioEngine.stop()
        //add Afzal
        audioEngine.inputNode?.removeTap(onBus: 0)
        
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        //end recording
        audioRecorder.stop()
        
        //finishButton.isHidden = false
        self.countdown.invalidate()
        self.hideTimer.invalidate()
        
        //self.countDownLabel.isHidden = true
        self.hideImages()
        self.introLabel.text = "Correct: \(self.correct) out of \(self.correct + self.incorrect)"
        //self.introLabel.isHidden = false
        self.findAcceleration()
        self.saveData()
        
        self.hideImages()
        
        let alert = UIAlertController(title: "Game Finished", message: "You have finished the game. Thank you for playing!", preferredStyle: UIAlertControllerStyle.alert)
        
        let alertAction = UIAlertAction(title: "Finish", style: .default){_ in
            //self.initializeGame()
            self.navigationController?.popViewController(animated: true)
            
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    //deal with acceleration data
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
    
    func saveData(){
        /*let appDelegate = UIApplication.shared.delegate as! AppDelegate
         
         let managedContext = appDelegate.managedObjectContext
         
         let entity: PictureResult =  NSEntityDescription.insertNewObject(forEntityName: "PictureResult", into: managedContext) as! PictureResult
         
         entity.correct = Int16(self.correct)
         entity.incorrect = Int16(self.incorrect)
         
         for acceleration in self.accelData {
         let newAccel: DeviceAcceleration =  NSEntityDescription.insertNewObject(forEntityName: "DeviceAcceleration", into: managedContext) as! DeviceAcceleration
         newAccel.x = acceleration.x
         newAccel.y = acceleration.y
         newAccel.z = acceleration.z
         newAccel.pictureResult = entity
         }
         
         do {
         try managedContext.save()
         pictureResults.append(entity)
         } catch let error as NSError  {
         print("Could not save \(error), \(error.userInfo)")
         }*/
    }
    
    //this function is used to record audio and transform it into a string
    func recordAndRecognizeSpeech(){
        let node = audioEngine.inputNode
        let recordingFormat = node?.outputFormat(forBus: 0)
        node?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            //recognizer not supported
            return
        }
        if !myRecognizer.isAvailable {
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: {result, error in
            if let result = result {
                var lastWord: String = ""
                let bestString = result.bestTranscription.formattedString
                
                //the audio API appends to a string each with each word the user says, so we need this loop to get the last word spoken - the newest color
                for segment in result.bestTranscription.segments {
                    let index = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastWord = String(bestString.suffix(from: index))
                    //lastWord = bestString.substring(from: index)
                    
                }
                //debugging print to console
                print(lastWord.lowercased())
                
                if(self.playerCanGuess){
                    self.checkWord(spokenWord: lastWord.lowercased())
                }
                
            } else if let error = error {
                print(error)
            }
        })
    }
    
}



// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}



