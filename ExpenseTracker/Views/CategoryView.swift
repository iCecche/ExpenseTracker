//
//  CategoryView.swift
//  ExpenseTracker
//
//  Created by alessio ceccherini on 26/10/25.
//

import Foundation
import SwiftUI

// MARK: - Categories List
struct CategoriesListView: View {
    let transactions: [Transaction]
    let categories: [Category]
    
    // Calculate spending per category
    func spendingForCategory(_ category: Category) -> Decimal {
        transactions
            .filter { $0.category?.id == category.id && $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    var topCategories: [(category: Category, amount: Decimal)] {
        categories
            .map { ($0, spendingForCategory($0)) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .prefix(4)
            .map { $0 }
    }
    
    var body: some View {
        ForEach(topCategories, id: \.category.id) { item in
            CategoryRowView(
                category: item.category,
                amount: item.amount
            )
        }
    }
}

// MARK: - Category Row
struct CategoryRowView: View {
    let category: Category
    let amount: Decimal
    
    @State private var animateBar = false
    
    // Assume a budget of 500 for visualization
    let categoryBudget: Decimal = 500
    
    var progress: Double {
        min(Double(truncating: (amount / categoryBudget) as NSDecimalNumber), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Icon
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundStyle(category.color)
                    .frame(width: 32)
                
                // Name
                Text(category.name)
                    .font(.body)
                
                Spacer()
                
                // Amount
                Text("€\(formatAmount(amount))")
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(category.color.gradient)
                        .frame(
                            width: animateBar ? geometry.size.width * progress : 0,
                            height: 6
                        )
                }
            }
            .frame(height: 6)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    animateBar = true
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let number = NSDecimalNumber(decimal: amount)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: number) ?? "0"
    }
}
