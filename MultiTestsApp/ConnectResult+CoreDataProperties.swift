//
//  ConnectResult+CoreDataProperties.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 7/18/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import CoreData


extension ConnectResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConnectResult> {
        return NSFetchRequest<ConnectResult>(entityName: "ConnectResult")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var maxXAcceleration: Double
    @NSManaged public var maxYAcceleration: Double
    @NSManaged public var maxZAcceleration: Double
    @NSManaged public var time: Double
    @NSManaged public var stylusAcceleration: NSSet?
    @NSManaged public var closestPoint: NSSet?
    @NSManaged public var point: NSSet?
    @NSManaged public var deviceAcceleration: NSSet?

}

// MARK: Generated accessors for stylusAcceleration
extension ConnectResult {

    @objc(addStylusAccelerationObject:)
    @NSManaged public func addToStylusAcceleration(_ value: StylusAcceleration)

    @objc(removeStylusAccelerationObject:)
    @NSManaged public func removeFromStylusAcceleration(_ value: StylusAcceleration)

    @objc(addStylusAcceleration:)
    @NSManaged public func addToStylusAcceleration(_ values: NSSet)

    @objc(removeStylusAcceleration:)
    @NSManaged public func removeFromStylusAcceleration(_ values: NSSet)

}

// MARK: Generated accessors for closestPoint
extension ConnectResult {

    @objc(addClosestPointObject:)
    @NSManaged public func addToClosestPoint(_ value: ClosestPoint)

    @objc(removeClosestPointObject:)
    @NSManaged public func removeFromClosestPoint(_ value: ClosestPoint)

    @objc(addClosestPoint:)
    @NSManaged public func addToClosestPoint(_ values: NSSet)

    @objc(removeClosestPoint:)
    @NSManaged public func removeFromClosestPoint(_ values: NSSet)

}

// MARK: Generated accessors for point
extension ConnectResult {

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
extension ConnectResult {

    @objc(addDeviceAccelerationObject:)
    @NSManaged public func addToDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(removeDeviceAccelerationObject:)
    @NSManaged public func removeFromDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(addDeviceAcceleration:)
    @NSManaged public func addToDeviceAcceleration(_ values: NSSet)

    @objc(removeDeviceAcceleration:)
    @NSManaged public func removeFromDeviceAcceleration(_ values: NSSet)

}
