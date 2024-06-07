//
//  InspectionTest+CoreDataProperties.swift
//  UserInspection
//
//  Created by Bhagwan Rajput on 07/06/24.
//
//

import Foundation
import CoreData


extension InspectionTest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InspectionTest> {
        return NSFetchRequest<InspectionTest>(entityName: "InspectionTest")
    }

    @NSManaged public var id: Int64
    @NSManaged public var surveyId: Int64
    @NSManaged public var inspectionTypeId: Int64
    @NSManaged public var areaName: String?
    @NSManaged public var areaId: Int64
    @NSManaged public var inspectionTypeName: String?
    @NSManaged public var access: String?
    @NSManaged public var categories: NSObject?

}

extension InspectionTest : Identifiable {

}
