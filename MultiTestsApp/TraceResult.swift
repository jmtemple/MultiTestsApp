//
//  TraceResult.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 12/5/16.
//  Copyright © 2016 NDMobileCompLab. All rights reserved.
//

import Foundation

class TraceResult {
    
    var averageDistance: Double // average distance from outline
    var totalDistance: Double // total distance from outline
    var crossedOutline: Int // number of times drawing crossed the outline
    var maxSpeed: Double // max speed in points per second
    var firstDistance: Double // first point's distance to outline
    var firstLastDistance: Double // distance between first and last point
    var time: Double // total time of trace
    
    init(average: Double, total: Double, crossed: Int, maxSpeed: Double, first: Double, firstLast: Double, time: Double) {
        self.time = time
        self.averageDistance = average
        self.totalDistance = total
        self.crossedOutline = crossed
        self.maxSpeed = maxSpeed
        self.firstDistance = first
        self.firstLastDistance = firstLast
        
    }
    
}
