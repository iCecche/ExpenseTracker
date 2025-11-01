//
//  BudgetCardView.swift
//  ExpenseTracker
//
//  Created by alessio ceccherini on 26/10/25.
//

import Foundation
import SwiftUI

// MARK: - Budget Card
struct BudgetCardView: View {
    let spent: Decimal
    let income: Decimal
    let budget: Decimal
    let progress: Double
    
    @State private var animateProgress = false
    
    var progressColor: Color {
        if progress < 0.7 { return .green }
        if progress < 0.9 { return .orange }
        return .red
    }
    
    var remaining: Decimal {
        budget - spent
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Budget Mensile")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("€\(formatAmount(spent))")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    
                    Text("di €\(formatAmount(budget))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Percentage Badge
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(progressColor)
                    
                    Text("€\(formatAmount(remaining)) rimasti")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(progressColor.gradient)
                        .frame(
                            width: animateProgress ? min(geometry.size.width * progress, geometry.size.width) : 0,
                            height: 12
                        )
                }
            }
            .frame(height: 12)
            .onAppear {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                    animateProgress = true
                }
            }
            
            // Quick Stats
            HStack(spacing: 16) {
                QuickStatView(
                    icon: "arrow.down.circle.fill",
                    title: "Spese",
                    value: "€\(formatAmount(spent))",
                    color: .red
                )
                
                Divider()
                
                QuickStatView(
                    icon: "arrow.up.circle.fill",
                    title: "Entrate",
                    value: "€\(formatAmount(income))",
                    color: .green
                )
            }
            .frame(height: 60)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let number = NSDecimalNumber(decimal: amount)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: number) ?? "0"
    }
}

// MARK: - Quick Stat
struct QuickStatView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }
            
            Spacer()
        }
    }
}
