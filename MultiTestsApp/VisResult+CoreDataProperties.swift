//
//  VisResult+CoreDataProperties.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 7/18/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import CoreData


extension VisResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VisResult> {
        return NSFetchRequest<VisResult>(entityName: "VisResult")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var stylusAcceleration: NSSet?
    @NSManaged public var closestPoints: NSSet?
    @NSManaged public var point: NSSet?
    @NSManaged public var deviceAcceleration: NSSet?

}

// MARK: Generated accessors for stylusAcceleration
extension VisResult {

    @objc(addStylusAccelerationObject:)
    @NSManaged public func addToStylusAcceleration(_ value: StylusAcceleration)

    @objc(removeStylusAccelerationObject:)
    @NSManaged public func removeFromStylusAcceleration(_ value: StylusAcceleration)

    @objc(addStylusAcceleration:)
    @NSManaged public func addToStylusAcceleration(_ values: NSSet)

    @objc(removeStylusAcceleration:)
    @NSManaged public func removeFromStylusAcceleration(_ values: NSSet)

}

// MARK: Generated accessors for closestPoints
extension VisResult {

    @objc(addClosestPointsObject:)
    @NSManaged public func addToClosestPoints(_ value: ClosestPoint)

    @objc(removeClosestPointsObject:)
    @NSManaged public func removeFromClosestPoints(_ value: ClosestPoint)

    @objc(addClosestPoints:)
    @NSManaged public func addToClosestPoints(_ values: NSSet)

    @objc(removeClosestPoints:)
    @NSManaged public func removeFromClosestPoints(_ values: NSSet)

}

// MARK: Generated accessors for point
extension VisResult {

    @objc(addPointObject:)
    @NSManaged public func addToPoint(_ value: Point)

    @objc(removePointObject:)
    @NSManaged public func removeFromPoint(_ value: Point)

    @objc(addPoint:)
    @NSManaged public func addToPoint(_ values: NSSet)

    @objc(removePoint:)
    @NSManaged public func removeFromPoint(_ values: NSSet)

}

// MARK: Generated accessors for deviceAcceleration
extension VisResult {

    @objc(addDeviceAccelerationObject:)
    @NSManaged public func addToDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(removeDeviceAccelerationObject:)
    @NSManaged public func removeFromDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(addDeviceAcceleration:)
    @NSManaged public func addToDeviceAcceleration(_ values: NSSet)

    @objc(removeDeviceAcceleration:)
    @NSManaged public func removeFromDeviceAcceleration(_ values: NSSet)

}
