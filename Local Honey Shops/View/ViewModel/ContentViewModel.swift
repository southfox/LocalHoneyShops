//
//  ContentViewModel.swift
//  Local Honey Shops
//
//  Created by Javier Fuchs on 27/09/2025.
//

import SwiftUI
import Combine

@MainActor
class ContentViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""

    private let repository: ShopRepository

    init(repository: ShopRepository) {
        self.repository = repository
    }
    
    func fetchItems() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedItems = try await repository.fetchShops()
            items = fetchedItems
        } catch {
            errorMessage = "Failed to load shops. Please try again later."
        }
        isLoading = false
    }
    
    var filteredItems: [Item] {
        guard !searchText.isEmpty else { return items }
        let search = searchText.lowercased()
        return items.filter { item in
            item.name.lowercased().contains(search) ||
            item.address.lowercased().contains(search) ||
            item.itemDescription.lowercased().contains(search)
        }
    }
}
