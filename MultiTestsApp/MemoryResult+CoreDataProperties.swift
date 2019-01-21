//
//  MemoryResult+CoreDataProperties.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 7/18/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import CoreData


extension MemoryResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemoryResult> {
        return NSFetchRequest<MemoryResult>(entityName: "MemoryResult")
    }

    @NSManaged public var elapsedTime: Double
    @NSManaged public var deviceAcceleration: NSSet?

}

// MARK: Generated accessors for deviceAcceleration
extension MemoryResult {

    @objc(addDeviceAccelerationObject:)
    @NSManaged public func addToDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(removeDeviceAccelerationObject:)
    @NSManaged public func removeFromDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(addDeviceAcceleration:)
    @NSManaged public func addToDeviceAcceleration(_ values: NSSet)

    @objc(removeDeviceAcceleration:)
    @NSManaged public func removeFromDeviceAcceleration(_ values: NSSet)

}
