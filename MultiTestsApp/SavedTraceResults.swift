//
//  SavedTraceResults.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 12/5/16.
//  Copyright © 2016 NDMobileCompLab. All rights reserved.
//

import Foundation

class SavedTraceResults: NSObject {
    private var results : [TraceResult]
    
    func addResult(newResult: TraceResult) {
        results.append(newResult)
    }
    func clear() {
        results.removeAll()
    }
    
    func count() -> Int {
        return results.count
    }
    
    func resultAtIndex(index: Int) -> TraceResult {
        return results[index]
    }

    func print() -> String {
        var str = ""
        for result in results {
            NSLog("average: \(result.averageDistance)\n")
            let totalTimeStr = String(format: "%.2f", result.time)
            let averageStr = String(format: "%.2f", result.averageDistance)
            let totalDistStr = String(format: "%.2f", result.totalDistance)
            let crossedTotalStr = String(Int(result.crossedOutline))
            let maxSpeed = String(format: "%.2f", result.maxSpeed)
            let firstDistStr = String(format: "%.2f", result.firstDistance)
            let firstLastDistStr = String(format: "%.2f", result.firstLastDistance)
            
            str.append("Total Time: \(totalTimeStr) s, Average Distance: \(averageStr) pts, Total Distance: \(totalDistStr) pts\n")
        }
 
        return str
    }
    
    override init() {
        self.results = [TraceResult]()
    }
    
}
