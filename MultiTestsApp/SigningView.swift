//
//  SigningView.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 4/13/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import UIKit

class SigningView: UIView {
    
    // This view draws the black outline so that the users know where to sign

    var lineColor: UIColor = UIColor.black
    let lineWidth: CGFloat = 3.0
    
    override func draw(_ rect: CGRect) {
        
        lineColor.setStroke()
        
        let point1 = CGPoint(x: 15, y: bounds.height - 50)
        let point2 = CGPoint(x: bounds.width - 15, y: bounds.height - 50)
        let line = UIBezierPath()
        line.move(to: point1)
        line.addLine(to: point2)

        line.lineWidth = lineWidth
        line.stroke()

        let square = UIBezierPath(rect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        square.lineWidth = lineWidth
        square.stroke()
        
        
    }


}
