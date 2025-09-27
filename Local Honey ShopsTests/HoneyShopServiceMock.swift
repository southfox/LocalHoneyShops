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

        // Wrap the test JSON array in the same structure as the real API
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "[]"
        let wrappedJSON = "{\"record\":\(jsonString)}"
        guard let data = wrappedJSON.data(using: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        return try await decode(data)
    }
}

