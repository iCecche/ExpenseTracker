//
//  ModifyTransactionView.swift
//  ExpenseTracker
//
//  Created by alessio ceccherini on 26/10/25.
//

import Foundation
import SwiftUI
import SwiftData

struct ModifyTransactionView: View {
    var transaction: Transaction
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Query private var categories: [Category]
    
    @State private var amount = ""
    @State private var merchant = ""
    @State private var selectedCategory: Category?
    @State private var notes = ""
    @State private var date = Date()
    @State private var transactionType: Transaction.TransactionType = .expense
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
                    Picker("Categoria", selection: $selectedCategory) {
                        Text("Nessuna").tag(nil as Category?)
                        ForEach(categories) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(category as Category?)
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
            .navigationTitle("Modifica Transazione")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(amount.isEmpty || merchant.isEmpty)
                }
            }
            .onAppear {
                // Prefill fields from existing transaction
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2
                amount = formatter.string(from: NSDecimalNumber(decimal: transaction.amount)) ?? ""
                merchant = transaction.merchant
                selectedCategory = transaction.category
                notes = transaction.notes ?? ""
                date = transaction.date
                transactionType = transaction.type
                //selectedRecurrency = transaction.isRecurrent
            }
        }
    }
    
    func saveChanges() {
        // Parse amount string to Decimal using NumberFormatter
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if let number = formatter.number(from: amount) {
            transaction.amount = number.decimalValue
        } else {
            return
        }

        transaction.merchant = merchant
        transaction.category = selectedCategory
        transaction.notes = notes.isEmpty ? nil : notes
        transaction.date = date
        transaction.type = transactionType
        //transaction.isRecurrent = selectedRecurrency

        do {
            try modelContext.save()
            dismiss()
        } catch {
            // You might want to handle the error with an alert in a future iteration
            dismiss()
        }
    }
}

