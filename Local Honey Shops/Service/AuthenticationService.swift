// AuthenticationService.swift
// Local Honey Shops
// Created by Javier Fuchs on 18/09/2025.

import Foundation

protocol AuthenticationService: AnyObject {
    // A stable identifier for the provider (e.g., "apple", "google", "firebase")
    var id: String { get }
    var name: String { get }
    var iconSystemName: String { get }
    var isAvailable: Bool { get }

    // Current user if signed in (persisted if service supports it)
    var currentUser: AuthUser? { get }

    // Start an interactive sign-in flow
    func signIn() async throws -> AuthUser

    // Clear session
    func signOut() async throws
}

