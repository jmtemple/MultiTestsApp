//
//  StylusAcceleration+CoreDataProperties.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 7/18/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import CoreData


extension StylusAcceleration {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StylusAcceleration> {
        return NSFetchRequest<StylusAcceleration>(entityName: "StylusAcceleration")
    }

    @NSManaged public var time: Double
    @NSManaged public var x: Double
    @NSManaged public var y: Double
    @NSManaged public var z: Double
    @NSManaged public var connectResult: ConnectResult?
    @NSManaged public var signatureResult: SignatureResult?
    @NSManaged public var traceResult: TraceResult?
    @NSManaged public var visResult: VisResult?

}
