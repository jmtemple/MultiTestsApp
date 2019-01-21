//
//  MyAudioRecorder.swift
//  cimontemplate
//
//  Created by Afzal Hossain on 4/28/17.
//  Copyright © 2017 Afzal Hossain. All rights reserved.
//

import AVFoundation
import UIKit

class MyAudioRecorder:NSObject, AVAudioRecorderDelegate{
    
    var audioRecorder: AVAudioRecorder?
    var audioFileName: URL?
    
    static let sharedInstance = MyAudioRecorder()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(notification:)),
                                               name: NSNotification.Name.AVAudioSessionInterruption,
                                               object: nil)
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    deinit {
        UIApplication.shared.endReceivingRemoteControlEvents()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
        
    }
    
    func startRecording(fileName: String){
        if self.audioRecorder?.isRecording != nil{
            return
        }
        let audioSession = AVAudioSession.sharedInstance()
        do{
            audioFileName = getDocumentsDirectory().appendingPathComponent("\(fileName).m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            try audioSession.setActive(true)
            try audioSession.setCategory(AVAudioSessionCategoryRecord, with: AVAudioSessionCategoryOptions.mixWithOthers )
            
            try audioRecorder = AVAudioRecorder(url: audioFileName!, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            
        } catch let error as NSError{
            print("An error occured..\(error)")
        }
        
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    @objc func handleInterruption(notification: NSNotification){
        let interruptionTypeAsObject =
            notification.userInfo![AVAudioSessionInterruptionTypeKey] as! NSNumber
        
        let interruptionType = AVAudioSessionInterruptionType(rawValue: UInt(interruptionTypeAsObject.uint32Value))
        
        if let type = interruptionType{
            if type == AVAudioSessionInterruptionType.ended{
                
                //resume()
                print("interruption ended in audio recording....")
                
            } else if type == AVAudioSessionInterruptionType.began{
                //InterruptedByCall = true
                //pause()
                print("interruption begin in audio recording.....")
            }
        }
        
    }
    
    
    func resume(){
        print("going to resume audio recording....")
        if audioRecorder != nil{
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            print("audio recording resumed")
        }
    }
    
    func isRecording()-> Bool{
        if self.audioRecorder != nil{
            return (self.audioRecorder?.isRecording)!
        }
        
        return false
    }
    
    func stop(){
        if self.audioRecorder != nil{
            if (self.audioRecorder?.isRecording)!{
                self.audioRecorder?.stop()
            }
            self.audioRecorder = nil
        }
        
        print("stop audio recording...")
    }
    
    func pause(){
        print("going to pause audio recording")
        if self.audioRecorder != nil{
            self.audioRecorder?.pause()
            print("audio recording paused")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        //delete the file
        print("audio recording has been stopped....")
    }
}


