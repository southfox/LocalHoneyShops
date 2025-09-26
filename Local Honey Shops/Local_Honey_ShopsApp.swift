//  Local_Honey_ShopsApp.swift
//  Local Honey Shops
//  Created by Javier Fuchs on 17/09/2025.

import SwiftUI
import SwiftData

@main
struct Local_Honey_ShopsApp: App {
    @StateObject private var auth = AuthViewModel(providers: [AppleSignInService()])

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
        }
        .modelContainer(sharedModelContainer)
    }
}

