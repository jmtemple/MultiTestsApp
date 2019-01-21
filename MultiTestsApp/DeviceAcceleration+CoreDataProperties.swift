//
//  DeviceAcceleration+CoreDataProperties.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 7/18/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import CoreData


extension DeviceAcceleration {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DeviceAcceleration> {
        return NSFetchRequest<DeviceAcceleration>(entityName: "DeviceAcceleration")
    }

    @NSManaged public var x: Double
    @NSManaged public var y: Double
    @NSManaged public var z: Double
    @NSManaged public var visResult: VisResult?
    @NSManaged public var traceResult: TraceResult?
    @NSManaged public var signatureResult: SignatureResult?
    @NSManaged public var pictureResult: PictureResult?
    @NSManaged public var circleAccel: MotorResult?
    @NSManaged public var squareAccel: MotorResult?
    @NSManaged public var motorResult: MotorResult?
    @NSManaged public var fallingBallResult: FallingBallResult?
    @NSManaged public var connectResult: ConnectResult?
    @NSManaged public var colorResult: ColorResult?
    @NSManaged public var memoryResult: MemoryResult?

}
