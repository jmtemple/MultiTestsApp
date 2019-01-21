//
//  Point+CoreDataProperties.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 7/18/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import CoreData


extension Point {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Point> {
        return NSFetchRequest<Point>(entityName: "Point")
    }

    @NSManaged public var time: Double
    @NSManaged public var x: Float
    @NSManaged public var y: Float
    @NSManaged public var connectResult: ConnectResult?
    @NSManaged public var signatureResult: SignatureResult?
    @NSManaged public var traceResult: TraceResult?
    @NSManaged public var visResult: VisResult?

}
