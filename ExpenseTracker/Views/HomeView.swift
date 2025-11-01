//
//  HomeView.swift
//  ExpenseTracker
//
//  Created by alessio ceccherini on 26/10/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Time Period Filter
enum TimePeriod: String, CaseIterable, Identifiable {
    case day = "Oggi"
    case week = "Settimana"
    case month = "Mese"
    case year = "Anno"
    case all = "Tutto"

    var id: String { rawValue }
}

// MARK: - Home Content
struct HomeContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    @Query private var budgets: [Budget]
    @Query private var categories: [Category]
    
    @State private var showAddExpense = false
    @State private var selectedPeriod: TimePeriod = .month
    
    // Transactions filtered by selected period
    var filteredTransactions: [Transaction] {
        let now = Date()
        switch selectedPeriod {
        case .day:
            return transactions.filter { Calendar.current.isDate($0.date, inSameDayAs: now) }
        case .week:
            return transactions.filter { Calendar.current.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }
        case .month:
            return transactions.filter { Calendar.current.isDate($0.date, equalTo: now, toGranularity: .month) }
        case .year:
            return transactions.filter { Calendar.current.isDate($0.date, equalTo: now, toGranularity: .year) }
        case .all:
            return transactions
        }
    }
    
    // Calculate spent amount
    var spent: Decimal {
        filteredTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    // Calculate income
    var income: Decimal {
        filteredTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    var budget: Decimal {
        switch selectedPeriod {
        case .month:
            return currentBudget?.limit ?? 1500
        default:
            return currentBudget?.limit ?? 1500
        }
    }
    
    var progress: Double {
        let denom = budget == 0 ? Decimal(1) : budget
        return Double(truncating: (spent / denom) as NSDecimalNumber)
    }
    
    // Recent transactions (last 5)
    var recentTransactions: [Transaction] {
        Array(filteredTransactions.sorted { $0.date > $1.date }.prefix(5))
    }
    
    var scheduledTransactions: [Transaction] {
        transactions.filter { $0.date > Date() }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    // Budget Card
                    Section {
                        BudgetCardView(
                            spent: spent,
                            income: income,
                            budget: budget,
                            progress: progress
                        )
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    
                    if !scheduledTransactions.isEmpty {
                        Section {
                            NavigationLink(destination: ScheduledTransactionsView(transactions: scheduledTransactions)) {
                                HStack {
                                    Text("Prossime spese")
                                    Spacer()
                                    Text("\(scheduledTransactions.count)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Image(systemName: "chevron.right")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        } header: {
                            Text("Programmate")
                        }
                    }
                    
                    // Categories Section
                    if !categories.isEmpty {
                        Section {
                            CategoriesListView(
                                transactions: filteredTransactions,
                                categories: categories
                            )
                        } header: {
                            Text("Categorie")
                        }
                    }
                    
                    // Recent Transactions
                    if !recentTransactions.isEmpty {
                        Section {
                            ForEach(recentTransactions) { transaction in
                                NavigationLink {
                                    TransactionDetailView(transaction: transaction)
                                } label: {
                                    TransactionRowView(transaction: transaction)
                                }
                            }
                            .onDelete(perform: deleteTransactions)
                        } header: {
                            Text("Recenti")
                        }
                    }
                }
                .navigationTitle(titleForSelectedPeriod)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Picker("Periodo", selection: $selectedPeriod) {
                            ForEach(TimePeriod.allCases) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 360)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .onAppear {
                    initializeDefaultCategories()
                    initializeDefaultBudget()
                }
                
                // Native iOS FAB
                Button(action: { showAddExpense = true }) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(.blue)
                        .clipShape(Circle())
                        .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                }
                .padding(24)
                .padding(.bottom, 8)
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView()
            }
        }
    }
    
    var titleForSelectedPeriod: String {
        switch selectedPeriod {
        case .day:
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE d MMMM"
            formatter.locale = Locale(identifier: "it_IT")
            return formatter.string(from: Date()).capitalized
        case .week:
            let cal = Calendar.current
            let now = Date()
            let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
            let end = cal.date(byAdding: .day, value: 6, to: start) ?? now
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            formatter.locale = Locale(identifier: "it_IT")
            let range = formatter.string(from: start) + " – " + formatter.string(from: end)
            return range
        case .month:
            return currentMonthName
        case .year:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            formatter.locale = Locale(identifier: "it_IT")
            return formatter.string(from: Date())
        case .all:
            return "All time"
        }
    }
    
    var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: Date()).capitalized
    }
    
    // Initialize default categories if empty
    private func initializeDefaultCategories() {
        if categories.isEmpty {
            for category in Category.defaultCategories {
                modelContext.insert(category)
            }
        }
    }
    
    // Initialize default budget if empty
    private func initializeDefaultBudget() {
        if currentBudget == nil {
            let budget = Budget(month: Date(), limit: 1500)
            modelContext.insert(budget)
        }
    }
    
    // Delete transactions
    private func deleteTransactions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recentTransactions[index])
        }
    }
    
    // Current month budget
    var currentBudget: Budget? {
        let now = Date()
        return budgets.first { Calendar.current.isDate($0.month, equalTo: now, toGranularity: .month) }
    }
}

struct ScheduledTransactionsView: View {
    var transactions: [Transaction]
    
    var body: some View {
        List {
            ForEach(transactions.sorted { $0.date < $1.date }) { transaction in
                NavigationLink {
                    TransactionDetailView(transaction: transaction)
                } label: {
                    TransactionRowView(transaction: transaction)
                }
            }
        }
        .navigationTitle("Spese Programmate")
    }
}
