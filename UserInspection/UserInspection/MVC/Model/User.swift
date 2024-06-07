//
//  User.swift
//  UserInspection
//
//  Created by Bhagwan Rajput on 07/06/24.
//

import Foundation

struct User: Codable {
    let email: String
    let password: String
}

struct APIResponse: Codable {
    var statusCode: Int?
    let error: String?
}

