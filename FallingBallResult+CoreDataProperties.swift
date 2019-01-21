//
//  FallingBallResult+CoreDataProperties.swift
//  MultiTestsApp
//
//  Created by Collin Klenke on 7/11/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//

import Foundation
import CoreData


extension FallingBallResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FallingBallResult> {
        return NSFetchRequest<FallingBallResult>(entityName: "FallingBallResult")
    }

    @NSManaged public var averageDistance: Double
    @NSManaged public var hits: Int16
    @NSManaged public var averageInnerDist: Double
    @NSManaged public var practiceAverageInnerDist: Double
    @NSManaged public var practiceAverageDist: Double
    @NSManaged public var practiceHits: Int16

}
