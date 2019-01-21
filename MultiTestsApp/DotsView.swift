//
//  DotsView.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 4/10/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import UIKit

class DotsView: UIView {
    
    // This view is used to see how accurate our data points are to the dots on the image/drawing
    // It is hidden on default

    let π: CGFloat = CGFloat(Double.pi)
    var lineColor: UIColor = UIColor.blue
    var radius: CGFloat = 15.0
    let lineWidth: CGFloat = 3.0
    var image = 0
    var width = 0
    var height = 0
    
    var points = [CGPoint]()
    
    override func draw(_ rect: CGRect) {
        
        lineColor.setStroke()
        
        for point in points {
            let center = CGPoint(x: point.x, y: point.y)
            let circle = UIBezierPath(arcCenter: center, radius: radius/2 - lineWidth/2, startAngle: 0, endAngle: 2*π, clockwise: true)
            circle.lineWidth = lineWidth
            circle.stroke()
        }
    }


}
