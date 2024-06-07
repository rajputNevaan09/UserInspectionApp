//
//  DataManager.swift
//  UserInspection
//
//  Created by Bhagwan Rajput on 07/06/24.
//
import CoreData

class DataManager {
    static let shared = DataManager()
    
    // Save an inspection
    func saveInspection(inspection: InspectionResponse, state: String) {
        let context = CoreDataStack.shared.context
        let inspectionEntity = InspectionTest(context: context)
        
        inspectionEntity.id = Int64(inspection.inspection.id)
        inspectionEntity.categories = inspection.inspection.survey.categories as NSObject
        inspectionEntity.areaId = Int64(inspection.inspection.area.id)
        inspectionEntity.areaName = inspection.inspection.area.name
        inspectionEntity.inspectionTypeId = Int64(inspection.inspection.inspectionType.id)
        inspectionEntity.inspectionTypeName = inspection.inspection.inspectionType.name
        inspectionEntity.access = inspection.inspection.inspectionType.access
        inspectionEntity.surveyId = Int64(inspection.inspection.survey.id)
        
        // Archive categories data
        do {
            let jsonData = try JSONEncoder().encode(inspection.inspection.survey.categories)
            let archivedData = try NSKeyedArchiver.archivedData(withRootObject: jsonData, requiringSecureCoding: false)
            inspectionEntity.categories = archivedData as NSObject?
        } catch {
            print("Failed to encode categories: \(error)")
        }
        
        CoreDataStack.shared.saveContext()
    }
    
    // Fetch inspections
    func fetchInspections() -> [InspectionTest] {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<InspectionTest> = InspectionTest.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch inspections: \(error)")
            return []
        }
    }
}
