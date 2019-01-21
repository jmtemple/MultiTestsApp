//
//  Utils.swift
//  PictureGame
//
//  Created by Afzal Hossain on 7/23/18.
//  Copyright © 2018 University of Notre Dame. All rights reserved.
//

import Foundation


class Utils{
    
    static func currentUnixTime() -> Int64{
        return Int64(NSDate().timeIntervalSince1970 * 1000)
    }
    static func currentUnixTimeUptoSec() -> Int64{
        return Int64(NSDate().timeIntervalSince1970)
    }
    static func currentLocalTime()-> String{
        let dateFormatter:DateFormatter? = DateFormatter()
        dateFormatter!.dateFormat = "MM_dd_yy_HH_mm_ss_SSSS"
        if let currentTime = dateFormatter!.string(from: NSDate() as Date) as String?{
            return currentTime
        } else{
            return ""
        }
    }
    
    static func timeOnly()-> String{
        let dateFormatter:DateFormatter? = DateFormatter()
        dateFormatter!.dateFormat = "HH_mm_ss_SSSS"
        if let currentTime = dateFormatter!.string(from: NSDate() as Date) as String!{
            return currentTime
        } else{
            return ""
        }
    }
    
    static func dateOnlyFromToday(days:Int)-> String{
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentTime:String = dateFormatter.string(from: NSDate().addingTimeInterval( TimeInterval(days) * 24 * 3600) as Date)
        return currentTime
    }
    
    
    static func formattedTime(date:NSDate)-> String{
        let dateFormatter:DateFormatter? = DateFormatter()
        dateFormatter!.dateFormat = "yyyy/MM/dd HH:mm:ss SSSS ZZZ"
        if let currentTime = dateFormatter!.string(from: date as Date) as String!{
            return currentTime
        } else{
            return ""
        }
    }
    
    static func simpleFormattedDateTime(date:NSDate)-> String{
        let dateFormatter:DateFormatter? = DateFormatter()
        dateFormatter!.dateFormat = "yyyy/MM/dd HH:mm:ss"
        if let currentTime = dateFormatter!.string(from: date as Date) as String!{
            return currentTime
        } else{
            return ""
        }
    }
    
    static func timeForFileName()-> String{
        let dateFormatter:DateFormatter? = DateFormatter()
        dateFormatter!.dateFormat = "yyyy_MM_dd_HH_mm_ss_SSSS_ZZZ"
        if let currentTime = dateFormatter!.string(from: NSDate() as Date) as String!{
            return currentTime
        } else{
            return ""
        }
    }

    
    static func getDataFromUserDefaults(key:String)->Any?{
        return UserDefaults.standard.object(forKey: key)
    }
    
    /**
     */
    static func removeDataFromUserDefault(key:String){
        UserDefaults.standard.removeObject(forKey:key)
    }
    
    static func saveDataToUserDefaults(data:Any, key:String){
        UserDefaults.standard.set(data, forKey: key)
    }


    
}
