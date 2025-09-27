// AuthViewModel.swift
// Local Honey Shops
// Created by Javier Fuchs on 18/09/2025.

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var currentUser: AuthUser?
    @Published private(set) var isSigningIn: Bool = false
    @Published private(set) var errorMessage: String?

    private var providersByID: [String: AuthenticationService]
    private var orderedProviders: [AuthenticationService]

    init(providers: [AuthenticationService]) {
        var dict: [String: AuthenticationService] = [:]
        for p in providers {
            dict[p.id] = p
        }
        self.providersByID = dict
        self.orderedProviders = providers
        // Restore existing session from the first provider that has one
        self.currentUser = providers.compactMap { $0.currentUser }.first
    }

    var providers: [AuthenticationService] {
        orderedProviders
    }

    func signIn(with providerID: String) async throws {
        guard let provider = providersByID[providerID] else {
            throw NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown provider \(providerID)"])
        }
        isSigningIn = true
        errorMessage = nil
        defer { isSigningIn = false }
        let user = try await provider.signIn()
        self.currentUser = user
    }

    func signOut() async throws {
        guard let user = currentUser, let provider = providersByID[user.providerID] else {
            return
        }
        try await provider.signOut()
        self.currentUser = nil
    }
}
