//
//  GreenView.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 10/18/16.
//  Copyright © 2016 NDMobileCompLab. All rights reserved.
//

import UIKit

class GreenView: UIButton {

    let π:CGFloat = CGFloat(M_PI)
    let color:UIColor = UIColor.green
    let gutter:CGFloat = 5
    var current = false
    
    override func draw(_ rect: CGRect) {
        let width: CGFloat = 3
        let radius: CGFloat = bounds.width - gutter
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        let path = UIBezierPath(arcCenter: center, radius: radius/2 - width/2, startAngle: 0, endAngle: 2*π, clockwise: true)
        path.lineWidth = width
        
        color.setStroke()
        color.setFill()
        path.stroke()
        path.fill()
        
        if (current) {
            let pathOutline = UIBezierPath(arcCenter: center, radius: (radius/2 - width/2) + 2, startAngle: 0, endAngle: 2*π, clockwise: true)
            pathOutline.lineWidth = 2
            UIColor.black.setStroke()
            pathOutline.stroke()
        }
    }

}
