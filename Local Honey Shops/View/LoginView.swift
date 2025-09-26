//  LoginView.swift
//  Local Honey Shops
//  Created by Javier Fuchs on 18/09/2025.

import SwiftUI

struct LoginSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var auth: AuthViewModel
    @State private var signInError: String?
    @State private var isWorking = false

    var body: some View {
        Form {
            Section(header: Text("Sign In")) {
                if let user = auth.currentUser {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Signed in as").font(.footnote).foregroundStyle(.secondary)
                        Text(user.displayName ?? "User").font(.headline)
                        if let email = user.email {
                            Text(email).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Text("Provider: \(user.providerID)").font(.footnote).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    // Only iCloud/Apple is implemented. Others are masked as "Coming soon".
                    Button {
                        Task {
                            await signIn(providerID: AppleSignInService.providerID)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "applelogo")
                            Text("Sign in with iCloud")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                    .disabled(isWorking)
                    .accessibilityLabel("Sign in with iCloud")

                    // Masked providers (disabled placeholders)
                    Group {
                        maskedProviderRow(title: "Sign in with Google", systemImage: "g.circle")
                        maskedProviderRow(title: "Sign in with Firebase", systemImage: "bolt.horizontal.circle")
                    }
                }

                if let error = signInError {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }

            Section {
                if auth.currentUser != nil {
                    Button(role: .destructive) {
                        Task {
                            await signOut()
                        }
                    } label: {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(isWorking)
                }

                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Close")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: auth.currentUser) { _, newUser in
            if newUser != nil {
                dismiss()
            }
        }
    }

    private func maskedProviderRow(title: String, systemImage: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
            Spacer()
            Text("Coming soon")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.secondary)
        .opacity(0.6)
        .contentShape(Rectangle())
        .onTapGesture { }
    }

    private func signIn(providerID: String) async {
        signInError = nil
        isWorking = true
        do {
            try await auth.signIn(with: providerID)
        } catch {
            signInError = error.localizedDescription
        }
        isWorking = false
    }

    private func signOut() async {
        signInError = nil
        isWorking = true
        do {
            try await auth.signOut()
        } catch {
            signInError = error.localizedDescription
        }
        isWorking = false
    }
}

#Preview("LoginSheetView") {
    NavigationStack {
        LoginSheetView()
            .environmentObject(AuthViewModel(providers: [AppleSignInService()]))
    }
}

