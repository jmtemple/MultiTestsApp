//
//  ClosestPoint+CoreDataProperties.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 7/18/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import CoreData


extension ClosestPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClosestPoint> {
        return NSFetchRequest<ClosestPoint>(entityName: "ClosestPoint")
    }

    @NSManaged public var distance: Double
    @NSManaged public var dotValue: Int16
    @NSManaged public var time: Double
    @NSManaged public var x: Float
    @NSManaged public var y: Float
    @NSManaged public var connectResult: ConnectResult?
    @NSManaged public var visResult: VisResult?

}
