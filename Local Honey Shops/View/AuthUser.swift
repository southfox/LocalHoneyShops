// AuthUser.swift
// Local Honey Shops
// Created by Javier Fuchs on 18/09/2025.

import Foundation

struct AuthUser: Equatable, Sendable {
    let id: String
    let displayName: String?
    let email: String?
    let providerID: String
}

