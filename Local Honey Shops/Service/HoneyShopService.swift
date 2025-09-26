//  HoneyShopService.swift
//  Local Honey Shops
//  Created by Javier Fuchs on 18/09/2025.

import Foundation

class HoneyShopService {
    static let shared = HoneyShopService()
    private let url = URL(string: "https://api.jsonbin.io/v3/b/68d6a50cae596e708ffcc69c")!
    private let masterKey = "$2b$10$mkTpzNK2udK.aJwWvW2/zecmwR5jqWkOmJ4lUTN1HNwFjgR0DaTAG"
    
    func fetch() async throws -> [Item] {
        var request = URLRequest(url: url)
        request.setValue(masterKey, forHTTPHeaderField: "X-Master-Key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        struct JSONResponse: Decodable {
            let record: [Item]
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let apiResponse = try decoder.decode(JSONResponse.self, from: data)
        return apiResponse.record
    }
}

