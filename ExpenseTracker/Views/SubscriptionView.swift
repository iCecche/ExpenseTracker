//
//  SubscriptionView.swift
//  ExpenseTracker
//
//  Created by alessio ceccherini on 26/10/25.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - Subscriptions View
struct SubscriptionsView: View {
    @Query private var subscriptions: [Subscription]
    
    var activeSubscriptions: [Subscription] {
        subscriptions.filter { $0.isActive }
    }
    
    var totalMonthly: Decimal {
        activeSubscriptions.reduce(0) { $0 + $1.monthlyAmount }
    }
    
    var totalYearly: Decimal {
        activeSubscriptions.reduce(0) { $0 + $1.annualAmount }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Totale Mensile")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("€\(formatDecimal(totalMonthly))")
                            .font(.system(.title, design: .rounded, weight: .bold))
                        
                        Text("€\(formatDecimal(totalYearly)) all'anno")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                if !activeSubscriptions.isEmpty {
                    Section {
                        ForEach(activeSubscriptions) { subscription in
                            SubscriptionRow(subscription: subscription)
                        }
                    } header: {
                        Text("Attivi")
                    }
                } else {
                    Section {
                        Text("Nessun abbonamento attivo")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Abbonamenti")
        }
    }
    
    private func formatDecimal(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "0.00"
    }
}

// MARK: - Subscription Row
struct SubscriptionRow: View {
    let subscription: Subscription
    
    var daysUntilRenew: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: subscription.nextDueDate).day ?? 0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill((subscription.category?.color ?? .blue).opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(subscription.category?.color ?? .blue)
                        .font(.body)
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(subscription.name)
                    .font(.body)
                
                if daysUntilRenew <= 3 && daysUntilRenew >= 0 {
                    Label("Rinnovo tra \(daysUntilRenew) giorni", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    Text("Rinnovo: \(subscription.nextDueDate, style: .date)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text("€\(formatDecimal(subscription.amount))")
                .font(.system(.body, design: .rounded, weight: .semibold))
        }
    }
    
    private func formatDecimal(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "0.00"
    }
}
