//
//  TransactionDetailsView.swift
//  ExpenseTracker
//
//  Created by alessio ceccherini on 26/10/25.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - Transaction Detail View
struct TransactionDetailView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State var showingDetail = false
    let transaction: Transaction
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Importo")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(transaction.displayAmount)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(transaction.type == .income ? .green : .primary)
                }
                
                HStack {
                    Text("Tipo")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(transaction.type.rawValue)
                }
                
                HStack {
                    Text("Commerciante")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(transaction.merchant)
                }
                
                HStack {
                    Text("Categoria")
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let category = transaction.category {
                        Label(category.name, systemImage: category.icon)
                            .foregroundStyle(category.color)
                    } else {
                        Text("Nessuna")
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack {
                    Text("Data")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(transaction.date, style: .date)
                }
                
                if let notes = transaction.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Note")
                            .foregroundStyle(.secondary)
                        Text(notes)
                    }
                }
            }
            
            Section {
                Button(action: {
                    self.showingDetail.toggle()
                }) {
                    Label("Modifica Transazione", systemImage: "pencil")
                }.sheet(isPresented: $showingDetail) {
                    ModifyTransactionView(transaction: transaction)
                }
                Button(role: .destructive) {
                    deleteTransaction()
                } label: {
                    Label("Elimina Transazione", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Dettaglio")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func deleteTransaction() {
        modelContext.delete(transaction)
        dismiss()
    }
}
