//  ShopRepository.swift
//  Local Honey Shops
//  Created by Javier Fuchs on 18/09/2025.

import Foundation

protocol ShopRepository {
    func fetchShops() async throws -> [Item]
}

// Abstraction for fetching shop data from any source.
// Concrete implementation using HoneyShopService (current network/JSON source)
struct RemoteShopRepository: ShopRepository {
    @MainActor
    func fetchShops() async throws -> [Item] {
        try await HoneyShopService.shared.fetch()
    }
}

// Example mock for previews or testing
struct MockShopRepository: ShopRepository {
    @MainActor
    func fetchShops() async throws -> [Item] {
        return [Item.default] // Add more mock data if needed
    }
}
