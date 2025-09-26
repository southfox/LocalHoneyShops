// HoneyShopServiceMock.swift
// Mock implementation for unit tests
// Created by Javier Fuchs on 18/09/2025.

import Foundation
@testable import Local_Honey_Shops

final class HoneyShopServiceMock: HoneyShopService, @unchecked Sendable {
    private let jsonData: Data

    init(json: String) {
        self.jsonData = Data(json.utf8)
        super.init()
    }

    // Override to return JSON from mock data instead of network
    override func fetch() async throws -> [Item] {
        struct JSONBinResponse: Decodable {
            let record: [Item]
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        // Simulate the same API response shape as the real service
        let wrapped = "{\"record\":\(jsonData.isEmpty ? "[]" : String(data: jsonData, encoding: .utf8) ?? "[]")}".data(using: .utf8)!
        let apiResponse = try decoder.decode(JSONBinResponse.self, from: wrapped)
        return apiResponse.record
    }
}

