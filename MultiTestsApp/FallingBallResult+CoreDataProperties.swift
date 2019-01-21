//
//  FallingBallResult+CoreDataProperties.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 7/18/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import CoreData


extension FallingBallResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FallingBallResult> {
        return NSFetchRequest<FallingBallResult>(entityName: "FallingBallResult")
    }

    @NSManaged public var averageDistance: Double
    @NSManaged public var averageInnerDist: Double
    @NSManaged public var hits: Int16
    @NSManaged public var practiceAverageDist: Double
    @NSManaged public var practiceAverageInnerDist: Double
    @NSManaged public var practiceHits: Int16
    @NSManaged public var deviceAcceleration: NSSet?

}

// MARK: Generated accessors for deviceAcceleration
extension FallingBallResult {

    @objc(addDeviceAccelerationObject:)
    @NSManaged public func addToDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(removeDeviceAccelerationObject:)
    @NSManaged public func removeFromDeviceAcceleration(_ value: DeviceAcceleration)

    @objc(addDeviceAcceleration:)
    @NSManaged public func addToDeviceAcceleration(_ values: NSSet)

    @objc(removeDeviceAcceleration:)
    @NSManaged public func removeFromDeviceAcceleration(_ values: NSSet)

}
