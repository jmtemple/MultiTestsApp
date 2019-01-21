//
//  TraceResult+CoreDataProperties.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 7/18/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import CoreData


extension TraceResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TraceResult> {
        return NSFetchRequest<TraceResult>(entityName: "TraceResult")
    }

    @NSManaged public var averageDistance: Double
    @NSManaged public var crossedOutline: Int16
    @NSManaged public var date: NSDate?
    @NSManaged public var firstDistance: Double
    @NSManaged public var firstLastDistance: Double
    @NSManaged public var maxSpeed: Double
    @NSManaged public var maxXAcceleration: Double
    @NSManaged public var maxYAcceleration: Double
    @NSManaged public var maxZAcceleration: Double
    @NSManaged public var time: Double
    @NSManaged public var totalDistance: Double
    @NSManaged public var speech: Bool
    @NSManaged public var stylusAcceleration: NSSet?
    @NSManaged public var point: NSSet?
    @NSManaged public var deviceAcceleration: NSSet?

}

// MARK: Generated accessors for stylusAcceleration
extension TraceResult {

    @objc(addStylusAccelerationObject:)
    @NSManaged public func addToStylusAcceleration(_ value: StylusAcceleration)

    @objc(removeStylusAccelerationObject:)
    @NSManaged public func removeFromStylusAcceleration(_ value: StylusAcceleration)

    @objc(addStylusAcceleration:)
    @NSManaged public func addToStylusAcceleration(_ values: NSSet)

    @objc(removeStylusAcceleration:)
    @NSManaged public func removeFromStylusAcceleration(_ values: NSSet)

}

// MARK: Generated accessors for point
extension TraceResult {

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
extension TraceResult {

    @objc(addDeviceAccelerationObject:)
    @NSManaged public func addToDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(removeDeviceAccelerationObject:)
    @NSManaged public func removeFromDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(addDeviceAcceleration:)
    @NSManaged public func addToDeviceAcceleration(_ values: NSSet)

    @objc(removeDeviceAcceleration:)
    @NSManaged public func removeFromDeviceAcceleration(_ values: NSSet)

}
