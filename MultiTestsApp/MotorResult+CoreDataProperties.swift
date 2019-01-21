//
//  MotorResult+CoreDataProperties.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 7/18/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import CoreData


extension MotorResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MotorResult> {
        return NSFetchRequest<MotorResult>(entityName: "MotorResult")
    }

    @NSManaged public var speech: Bool
    @NSManaged public var circleAccel: NSSet?
    @NSManaged public var squareAccel: NSSet?
    @NSManaged public var deviceAcceleration: NSSet?

}

// MARK: Generated accessors for circleAccel
extension MotorResult {

    @objc(addCircleAccelObject:)
    @NSManaged public func addToCircleAccel(_ value: DeviceAcceleration)

    @objc(removeCircleAccelObject:)
    @NSManaged public func removeFromCircleAccel(_ value: DeviceAcceleration)

    @objc(addCircleAccel:)
    @NSManaged public func addToCircleAccel(_ values: NSSet)

    @objc(removeCircleAccel:)
    @NSManaged public func removeFromCircleAccel(_ values: NSSet)

}

// MARK: Generated accessors for squareAccel
extension MotorResult {

    @objc(addSquareAccelObject:)
    @NSManaged public func addToSquareAccel(_ value: DeviceAcceleration)

    @objc(removeSquareAccelObject:)
    @NSManaged public func removeFromSquareAccel(_ value: DeviceAcceleration)

    @objc(addSquareAccel:)
    @NSManaged public func addToSquareAccel(_ values: NSSet)

    @objc(removeSquareAccel:)
    @NSManaged public func removeFromSquareAccel(_ values: NSSet)

}

// MARK: Generated accessors for deviceAcceleration
extension MotorResult {

    @objc(addDeviceAccelerationObject:)
    @NSManaged public func addToDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(removeDeviceAccelerationObject:)
    @NSManaged public func removeFromDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(addDeviceAcceleration:)
    @NSManaged public func addToDeviceAcceleration(_ values: NSSet)

    @objc(removeDeviceAcceleration:)
    @NSManaged public func removeFromDeviceAcceleration(_ values: NSSet)

}
