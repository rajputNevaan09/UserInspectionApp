//
//  NetworkManager.swift
//  UserInspection
//
//  Created by Bhagwan Rajput on 07/06/24.
//

import Foundation
import UIKit

class NetworkManager {
    
    static let shared = NetworkManager()
    
    func fetchInspectionData(completion: @escaping (Result<InspectionResponse, Error>) -> Void) {
        let urlString = API.baseUrl+API.startInspectionURL
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let inspectionResponse = try decoder.decode(InspectionResponse.self, from: data)
                completion(.success(inspectionResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func submitInspection(_ inspection: InspectionResponse, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: API.baseUrl+API.submitInspectionURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(inspection)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                completion(.success(responseString))
            } else {
                completion(.failure(NSError(domain: "Unable to parse response", code: 0, userInfo: nil)))
            }
        }.resume()
    }
    
}

