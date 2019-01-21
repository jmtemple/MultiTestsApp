//
//  PictureResult+CoreDataProperties.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 7/18/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import CoreData


extension PictureResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PictureResult> {
        return NSFetchRequest<PictureResult>(entityName: "PictureResult")
    }

    @NSManaged public var correct: Int16
    @NSManaged public var incorrect: Int16
    @NSManaged public var deviceAcceleration: NSSet?

}

// MARK: Generated accessors for deviceAcceleration
extension PictureResult {

    @objc(addDeviceAccelerationObject:)
    @NSManaged public func addToDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(removeDeviceAccelerationObject:)
    @NSManaged public func removeFromDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(addDeviceAcceleration:)
    @NSManaged public func addToDeviceAcceleration(_ values: NSSet)

    @objc(removeDeviceAcceleration:)
    @NSManaged public func removeFromDeviceAcceleration(_ values: NSSet)

}
