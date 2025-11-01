//
//  AddTransactionView.swift
//  ExpenseTracker
//
//  Created by alessio ceccherini on 26/10/25.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - Add Expense View
struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Query private var categories: [Category]
    
    @State private var amount = ""
    @State private var merchant = ""
    @State private var selectedCategory: Category?
    @State private var notes = ""
    @State private var date = Date()
    @State private var transactionType: Transaction.TransactionType = .expense
    @State private var isRecurrent: Bool = false
    @State private var selectedRecurrency: Subscription.BillingFrequency = .never
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("€")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.system(.title, design: .rounded, weight: .semibold))
                    }
                    
                    Picker("Tipo", selection: $transactionType) {
                        Text("Spesa").tag(Transaction.TransactionType.expense)
                        Text("Entrata").tag(Transaction.TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    TextField("Es. Supermercato", text: $merchant)
                    
                    DatePicker("Data", selection: $date, displayedComponents: .date)
                } header: {
                    Text("Dettagli")
                }
                
                Section {
                    NavigationLink {
                        CategoryPickerView(selected: $selectedCategory)
                    } label: {
                        HStack(spacing: 5) {
                            Text("Categoria")
                            Spacer()
                            if let selectedCategory {
                                Label(selectedCategory.name, systemImage: selectedCategory.icon)
                                    .foregroundStyle(selectedCategory.color)
                                    .labelIconToTitleSpacing(5)
                            } else {
                                Text("Nessuna")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Categoria")
                }
                
                Section {
                    Picker("Ripetizione", selection: $selectedRecurrency) {
                        ForEach(Subscription.BillingFrequency.allCases) { recurrency in
                            Text(recurrency.rawValue)
                                .tag(recurrency) 
                        }
                    }
                } header: {
                    Text("Ripetizione")
                }
                
                Section {
                    TextField("Aggiungi nota (opzionale)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Note")
                }
            }
            .navigationTitle("Nuova Transazione")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aggiungi") {
                        addTransaction()
                    }
                    .fontWeight(.semibold)
                    .disabled(amount.isEmpty || merchant.isEmpty)
                }
            }
        }
    }
    
    private func addTransaction() {
        guard let amountValue = Decimal(string: amount) else { return }
        
        if (selectedRecurrency != .never) {
            let subscription = Subscription(
                name: merchant,
                amount: amountValue,
                frequency: selectedRecurrency,
                nextDueDate: Subscription.nextDate(for: selectedRecurrency, from: date),
                category: selectedCategory,
                isActive: true,
                notes: notes
            )
            modelContext.insert(subscription)
        }else {
            let transaction = Transaction(
                amount: amountValue,
                date: date,
                merchant: merchant,
                notes: notes.isEmpty ? nil : notes,
                category: selectedCategory,
                receiptImg: nil,
                type: transactionType,
            )
            modelContext.insert(transaction)
        }
        dismiss()
    }
}

