//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by alessio ceccherini on 26/10/25.
//

import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self, Category.self, Subscription.self, Budget.self
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
            ExpenseTrackerHomeView()
        }
        .modelContainer(for: [Transaction.self, Category.self, Subscription.self, Budget.self])
    }
}
