//
//  InspectionData.swift
//  UserInspection
//
//  Created by Bhagwan Rajput on 07/06/24.
//

import Foundation

struct InspectionResponse: Codable {
    let inspection: Inspection
}

struct Inspection: Codable {
    let area: Area
    let id: Int
    let inspectionType: InspectionType
    let survey: Survey
}

struct Area: Codable {
    let id: Int
    let name: String
}

struct InspectionType: Codable {
    let access: String
    let id: Int
    let name: String
}

struct Survey: Codable {
    let categories: [Category]
    let id: Int
}

struct Category: Codable {
    let id: Int
    let name: String
    let questions: [Question]
}

struct Question: Codable {
    let answerChoices: [AnswerChoice]
    let id: Int
    let name: String
    let selectedAnswerChoiceId: Int?
}

struct AnswerChoice: Codable {
    let id: Int
    let name: String
    let score: Double
}
