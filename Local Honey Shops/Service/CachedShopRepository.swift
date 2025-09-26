//  CachedShopRepository.swift
//  Local Honey Shops
//  Created by Javier Fuchs on 18/09/2025.

import Foundation

// Provides offline caching for Honey shop data.
struct CachedShopRepository: ShopRepository {
    let remote: ShopRepository
    let cacheFileName = "Honey_shops_cache.json"
    
    private var cacheURL: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(cacheFileName)
    }

    @MainActor
    func fetchShops() async throws -> [Item] {
        // Try loading from cache first
        if let cached = loadCachedItems() {
            return cached
        }
        // Else fetch remote and cache
        let fetched = try await remote.fetchShops()
        cacheItems(fetched)
        return fetched
    }
    
    private func loadCachedItems() -> [Item]? {
        guard let url = cacheURL, let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([Item].self, from: data)
    }
    
    private func cacheItems(_ items: [Item]) {
        guard let url = cacheURL else { return }
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: url)
        }
    }
}
