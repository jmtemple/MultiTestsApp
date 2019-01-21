//
//  DemoView.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 11/29/16.
//  Copyright © 2016 NDMobileCompLab. All rights reserved.
//

import UIKit

class DemoView: UIView {

    let π:CGFloat = CGFloat(M_PI)
    var lineColor:UIColor = UIColor.blue
    let gutter:CGFloat = 60 // space between the view and the outline of the shape
    var radius:CGFloat = 0.0 // value of radius is set in TraceShapeViewController viewDidLoad()
    let lineWidth:CGFloat = 5.0
    let imageName = "finger"

    override func draw(_ rect: CGRect) {
        
        lineColor.setStroke()
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)

        // draw blue segments over black outline to make dashed line
        for i in 0...7 {
            if (i%2 == 0) {
                let start = π + (π/2.0)*(CGFloat(i)/7)
                let end = π + (π/2.0)*(CGFloat(i)/7) + (π/2.0)*(1.0/7.0)
                let seg = UIBezierPath(arcCenter: center, radius: radius/2 - lineWidth/3, startAngle: start, endAngle: end, clockwise: true)
                seg.lineWidth = lineWidth + 2
                seg.stroke()
            }
        }
        
        // draw triangle for arrow
        lineColor.setStroke()
        lineColor.setFill()
        let point1 = CGPoint(x: center.x, y: center.y - 15 - radius/2 + lineWidth/3)
        let point2 = CGPoint(x: center.x, y: center.y + 15 - radius/2 + lineWidth/3)
        let point3 = CGPoint(x: center.x + 20, y: center.y - radius/2 + lineWidth/3)
        let triangle = UIBezierPath()
        triangle.move(to: point1)
        triangle.addLine(to: point2)
        triangle.addLine(to: point3)
        triangle.addLine(to: point1)
        triangle.fill()
        triangle.stroke()
        
        // displaying the finger image
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: center.x - radius/2 - 33, y: center.y, width: 100, height: 100)
        self.addSubview(imageView)
        
    }

}
