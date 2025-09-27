// ContentViewModel.swift
// Local Honey Shops
// Created by Javier Fuchs on 18/09/2025.

import SwiftUI
import Combine
import MapKit

private enum ContentDisplayMode: String, CaseIterable, Identifiable {
    case list = "List"
    case map = "Map"
    var id: String { rawValue }
}

struct ContentView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var viewModel: ContentViewModel
    @State private var displayMode: ContentDisplayMode = .list
    @State private var showingLogin = false
    
    init(repository: ShopRepository = CachedShopRepository(remote: RemoteShopRepository())) {
        self._viewModel = StateObject(wrappedValue: ContentViewModel(repository: repository))
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
            .task {
                await viewModel.fetchItems()
            }
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

