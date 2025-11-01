//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by alessio ceccherini on 26/10/25.
//

import SwiftUI
import SwiftData


// MARK: - Main View
struct ExpenseTrackerHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeContentView()
                .tabItem {
                    Label("Panoramica", systemImage: "chart.pie.fill")
                }
                .tag(0)
            
            StatsView()
                .tabItem {
                    Label("Statistiche", systemImage: "chart.bar.fill")
                }
                .tag(1)

            SubscriptionsView()
                .tabItem {
                    Label("Abbonamenti", systemImage: "arrow.clockwise")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Impostazioni", systemImage: "gear")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}

// MARK: - Data Models for Charts
struct MonthData: Identifiable {
    let id = UUID()
    let month: String
    let amount: Int
}

struct PieData: Identifiable {
    let id = UUID()
    let name: String
    let amount: Int
    let color: Color
}

// MARK: - Preview
#Preview {
    ExpenseTrackerHomeView()
        .modelContainer(for: [Transaction.self, Category.self, Subscription.self, Budget.self], inMemory: true)
}
