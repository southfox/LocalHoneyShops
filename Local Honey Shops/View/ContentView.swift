// ContentViewModel.swift
// Local Honey Shops
// Created by Javier Fuchs on 18/09/2025.

import SwiftUI
import Combine
import MapKit

@MainActor
class ContentViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""

    private let repository: ShopRepository

    init(repository: ShopRepository) {
        self.repository = repository
        Task { await fetchItems() }
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

private enum ContentDisplayMode: String, CaseIterable, Identifiable {
    case list = "List"
    case map = "Map"
    var id: String { rawValue }
}

@MainActor
struct ContentView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject var viewModel: ContentViewModel
    @State private var displayMode: ContentDisplayMode = .list
    @State private var showingLogin = false
    
    @MainActor
    init(repository: ShopRepository = CachedShopRepository(remote: RemoteShopRepository())) {
        _viewModel = StateObject(wrappedValue: ContentViewModel(repository: repository))
    }
    
    var body: some View {
        NavigationSplitView {
            VStack(spacing: 8) {
                Picker("Display", selection: $displayMode) {
                    ForEach(ContentDisplayMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])

                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .padding()
                    } else {
                        switch displayMode {
                        case .list:
                            List(viewModel.filteredItems) { item in
                                NavigationLink {
                                    ShopDetailView(shop: item)
                                } label: {
                                    ShopCardView(shop: item, searchText: viewModel.searchText)
                                }
                            }
                            .refreshable {
                                await viewModel.fetchItems()
                            }
                        case .map:
                            ShopsMapView(shops: viewModel.filteredItems)
                                .ignoresSafeArea(edges: .bottom)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Search Honey Shops")
            .navigationTitle("Honey Shops")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingLogin = true
                    } label: {
                        Image(systemName: auth.currentUser == nil ? "person.crop.circle" : "person.crop.circle.fill")
                            .imageScale(.large)
                    }
                    .accessibilityLabel(auth.currentUser == nil ? "Sign In" : "Account")
                }
            }
            .sheet(isPresented: $showingLogin) {
                NavigationStack {
                    LoginSheetView()
                        .environmentObject(auth)
                }
            }
        } detail: {
            Text("Select a shop")
        }
    }
}


#Preview {
    ContentView(repository: MockShopRepository())
        .environmentObject(AuthViewModel(providers: [AppleSignInService()]))
}

