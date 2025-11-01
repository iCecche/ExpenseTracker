//
//  RecentTransactionView.swift
//  ExpenseTracker
//
//  Created by alessio ceccherini on 26/10/25.
//

import Foundation
import SwiftUI

// MARK: - Transaction Row
struct TransactionRowView: View {
    let transaction: Transaction
    
    var isIncome: Bool {
        transaction.type == .income
    }
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill((transaction.category?.color ?? .blue).opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: transaction.category?.icon ?? "questionmark")
                    .foregroundStyle(transaction.category?.color ?? .blue)
                    .font(.body)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.merchant)
                    .font(.body)
                
                HStack(spacing: 4) {
                    Text(transaction.category?.name ?? "Altro")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(formatDate(date: transaction.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Amount
            Text(transaction.displayAmount)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(isIncome ? .green : .primary)
        }
        .padding(.vertical, 4)
    }
}
