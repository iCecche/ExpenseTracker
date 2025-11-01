//
//  StatsView.swift
//  ExpenseTracker
//
//  Created by alessio ceccherini on 26/10/25.
//

import Foundation
import SwiftUI
import SwiftData
import Charts

// MARK: - Stats View
struct StatsView: View {
    @Query private var transactions: [Transaction]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Monthly Chart
                    MonthlyChartView(transactions: transactions)
                        .frame(height: 220)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                    
                    // Category Distribution
                    CategoryDistributionView(transactions: transactions)
                        .frame(height: 300)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistiche")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Monthly Chart
struct MonthlyChartView: View {
    let transactions: [Transaction]
    
    var monthlyData: [MonthData] {
        let calendar = Calendar.current
        let last6Months = (0..<6).map { calendar.date(byAdding: .month, value: -$0, to: Date())! }
        
        return last6Months.reversed().map { date in
            let monthTransactions = transactions.filter { transaction in
                calendar.isDate(transaction.date, equalTo: date, toGranularity: .month) &&
                transaction.type == .expense
            }
            let total = monthTransactions.reduce(Decimal(0)) { $0 + $1.amount }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            formatter.locale = Locale(identifier: "it_IT")
            
            return MonthData(
                month: formatter.string(from: date).capitalized,
                amount: Int(truncating: total as NSDecimalNumber)
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spese Mensili")
                .font(.headline)
            
            Chart(monthlyData) { item in
                BarMark(
                    x: .value("Mese", item.month),
                    y: .value("Spesa", item.amount)
                )
                .foregroundStyle(.blue.gradient)
                .cornerRadius(6)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Int.self) {
                            Text("€\(amount)")
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Category Distribution
struct CategoryDistributionView: View {
    let transactions: [Transaction]
    
    var categoryData: [PieData] {
        let currentMonth = Date()
        let monthTransactions = transactions.filter { transaction in
            Calendar.current.isDate(transaction.date, equalTo: currentMonth, toGranularity: .month) &&
            transaction.type == .expense
        }
        
        var categoryTotals: [String: (amount: Decimal, color: Color)] = [:]
        
        for transaction in monthTransactions {
            let categoryName = transaction.category?.name ?? "Altro"
            let categoryColor = transaction.category?.color ?? .gray
            
            if let existing = categoryTotals[categoryName] {
                categoryTotals[categoryName] = (existing.amount + transaction.amount, categoryColor)
            } else {
                categoryTotals[categoryName] = (transaction.amount, categoryColor)
            }
        }
        
        return categoryTotals.map { name, data in
            PieData(
                name: name,
                amount: Int(truncating: data.amount as NSDecimalNumber),
                color: data.color
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    var total: Int {
        categoryData.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distribuzione per Categoria")
                .font(.headline)
            
            if !categoryData.isEmpty {
                Chart(categoryData) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(item.color.gradient)
                    .cornerRadius(4)
                }
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(categoryData) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 10, height: 10)
                            
                            Text(item.name)
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("€\(item.amount)")
                                .font(.caption.weight(.semibold))
                            
                            if total > 0 {
                                Text("(\(Int(Double(item.amount) / Double(total) * 100))%)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.top, 8)
            } else {
                Text("Nessun dato disponibile")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
}
