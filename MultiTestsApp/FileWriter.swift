//
//  FileWriter.swift
//  PictureGame
//
//  Created by Afzal Hossain on 6/16/18.
//  Copyright © 2018 University of Notre Dame. All rights reserved.
//

import Foundation

class FileWriter:NSObject {
    
    
    var logBackgroundQueue:DispatchQueue? = DispatchQueue(label: "logqueue")
    var currentFileName:String = ""
    var directory = FileWriter.defaultDirectory()
    
    static let sharedInstance = FileWriter()
    
    override init() {
        super.init()
    }

    
    func write(text: String) {
        self.logBackgroundQueue?.async {
            if self.currentFileName.isEmpty{
                return
            }
            let path = "\(self.directory)/\(self.currentFileName)"
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: path) {
                do{
                    try "".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                } catch let error as NSError{
                    print("An error occured..\(error)")
                }
                
            }
            if let fileHandle = FileHandle(forWritingAtPath: path) {
                var writeText:String! = "\(text)"
                if writeText.hasSuffix("\n"){
                    //do nothing
                }else{
                    writeText = "\(text)\n"
                }

                fileHandle.seekToEndOfFile()
                fileHandle.write(writeText.data(using: String.Encoding.utf8)!)
                fileHandle.closeFile()
            }
        }
    }
    static func defaultDirectory() -> String {
        var path = ""
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        path = "\(paths[0])/Logs"

        if !fileManager.fileExists(atPath: path) && path != ""  {
            do{
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError{
                print("An error occured..\(error)")
            }
            
        }
        return path
    }
    
    func setFileName(name:String){
        currentFileName = "\(name).csv"
    }
}
