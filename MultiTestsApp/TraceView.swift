//
//  TraceView.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 10/4/16.
//  Copyright © 2016 NDMobileCompLab. All rights reserved.
//

import UIKit

class TraceView: UIView {

    let π: CGFloat = CGFloat(Double.pi)
    var lineColor: UIColor = UIColor.black
    var circle: Int = 1 // 1 = circle, -1 = square
    let gutter: CGFloat = 60 // space between the view and the outline of the shape
    var radius: CGFloat = 0.0 // value of radius is set in TraceShapeViewController viewDidLoad()
    let lineWidth: CGFloat = 3.0
    
    override func draw(_ rect: CGRect) {
        
        lineColor.setStroke()
        
        if (circle == 1) { // drawing the circle
            let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
            let circle = UIBezierPath(arcCenter: center, radius: radius/2 - lineWidth/2, startAngle: 0, endAngle: 2*π, clockwise: true)
            circle.lineWidth = lineWidth
            circle.stroke()
                        
        } else { // drawing the square
            let x = (bounds.width/2) - radius/2
            let y = (bounds.height/2) - radius/2
            let square = UIBezierPath(rect: CGRect(x: x, y: y, width: radius, height: radius))
            square.lineWidth = lineWidth
            square.stroke()
        }
        
    }

}
