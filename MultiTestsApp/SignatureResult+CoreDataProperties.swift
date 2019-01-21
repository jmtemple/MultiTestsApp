//
//  SignatureResult+CoreDataProperties.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 7/18/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import CoreData


extension SignatureResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SignatureResult> {
        return NSFetchRequest<SignatureResult>(entityName: "SignatureResult")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var image: NSData?
    @NSManaged public var maxXAcceleration: Double
    @NSManaged public var maxYAcceleration: Double
    @NSManaged public var maxZAcceleration: Double
    @NSManaged public var time: Double
    @NSManaged public var stylusAcceleration: NSSet?
    @NSManaged public var point: NSSet?
    @NSManaged public var deviceAcceleration: NSSet?

}

// MARK: Generated accessors for stylusAcceleration
extension SignatureResult {

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
extension SignatureResult {

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
extension SignatureResult {

    @objc(addDeviceAccelerationObject:)
    @NSManaged public func addToDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(removeDeviceAccelerationObject:)
    @NSManaged public func removeFromDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(addDeviceAcceleration:)
    @NSManaged public func addToDeviceAcceleration(_ values: NSSet)

    @objc(removeDeviceAcceleration:)
    @NSManaged public func removeFromDeviceAcceleration(_ values: NSSet)

}
