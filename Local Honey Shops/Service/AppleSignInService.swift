// AppleSignInService.swift
// Local Honey Shops
// Created by Javier Fuchs on 18/09/2025.

import Foundation
import AuthenticationServices
import UIKit
import ObjectiveC

final class AppleSignInService: NSObject, AuthenticationService {

    static let providerID = "apple"

    // MARK: AuthenticationService
    var id: String { Self.providerID }
    var name: String { "iCloud" }
    var iconSystemName: String { "applelogo" }
    var isAvailable: Bool { true }

    private let userDefaults = UserDefaults.standard

    private enum Keys {
        static let userID = "appleUserID"
        static let givenName = "appleUserGivenName"
        static let familyName = "appleUserFamilyName"
        static let email = "appleUserEmail"
    }

    var currentUser: AuthUser? {
        guard let userID = userDefaults.string(forKey: Keys.userID) else { return nil }
        let given = userDefaults.string(forKey: Keys.givenName)
        let family = userDefaults.string(forKey: Keys.familyName)
        let displayName: String?
        if let g = given, let f = family, !g.isEmpty || !f.isEmpty {
            displayName = [g, f].compactMap { $0 }.joined(separator: " ")
        } else {
            displayName = nil
        }
        let email = userDefaults.string(forKey: Keys.email)
        return AuthUser(id: userID, displayName: displayName, email: email, providerID: id)
    }

    func signIn() async throws -> AuthUser {
        try await withCheckedThrowingContinuation { continuation in
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = Delegate(
                onSuccess: { credential in
                    let userID = credential.user
                    // Persist stable user identifier
                    self.userDefaults.set(userID, forKey: Keys.userID)
                    // Name is only provided on first authorization; store it if present
                    if let name = credential.fullName {
                        if let given = name.givenName, !given.isEmpty {
                            self.userDefaults.set(given, forKey: Keys.givenName)
                        }
                        if let family = name.familyName, !family.isEmpty {
                            self.userDefaults.set(family, forKey: Keys.familyName)
                        }
                    }
                    if let email = credential.email, !email.isEmpty {
                        self.userDefaults.set(email, forKey: Keys.email)
                    }
                    let user = self.currentUser!
                    continuation.resume(returning: user)
                },
                onFailure: { error in
                    continuation.resume(throwing: error)
                }
            )
            controller.delegate = delegate
            controller.presentationContextProvider = delegate
            // Keep delegate alive during the request
            objc_setAssociatedObject(controller, &AssociatedKeys.delegate, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            controller.performRequests()
        }
    }

    func signOut() async throws {
        userDefaults.removeObject(forKey: Keys.userID)
        userDefaults.removeObject(forKey: Keys.givenName)
        userDefaults.removeObject(forKey: Keys.familyName)
        userDefaults.removeObject(forKey: Keys.email)
    }

    // MARK: - Private

    private struct AssociatedKeys {
        static var delegate: UInt8 = 0
    }

    private final class Delegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        let onSuccess: (ASAuthorizationAppleIDCredential) -> Void
        let onFailure: (Error) -> Void

        init(onSuccess: @escaping (ASAuthorizationAppleIDCredential) -> Void,
             onFailure: @escaping (Error) -> Void) {
            self.onSuccess = onSuccess
            self.onFailure = onFailure
        }

        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            // Best-effort to get a key window for presentation in SwiftUI apps
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }
            let window = windowScene?.keyWindow ?? windowScene?.windows.first
            // If we couldn't find a current window, fall back to a new UIWindow()
            // (ASPresentationAnchor is a typealias to UIWindow on iOS)
            return window ?? UIWindow()
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                onSuccess(credential)
            } else {
                onFailure(NSError(domain: "AppleSignInService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported credential type."]))
            }
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            onFailure(error)
        }
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? {
        // iOS 15+ safe way to get key window
        return windows.first { $0.isKeyWindow }
    }
}
