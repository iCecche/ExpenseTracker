//
//  Item.swift
//  ExpenseTracker
//
//  Created by alessio ceccherini on 26/10/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Transaction {
    var id: UUID
    var amount: Decimal
    var date: Date
    var merchant: String
    var notes: String?
    var category: Category?
    var colorHex: String?
    var receiptImg: Data?
    var type: TransactionType
    
    // Non-persisted computed color derived from hex
    var color: Color? {
        guard let colorHex else { return nil }
        return Color(hex: colorHex)
    }
    
    init(amount: Decimal, date: Date, merchant: String, notes: String? = nil, category: Category? = nil, colorHex: String? = nil, receiptImg: Data? = nil, type: TransactionType,) {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.merchant = merchant
        self.notes = notes
        self.category = category
        self.colorHex = colorHex
        self.receiptImg = receiptImg
        self.type = type
    }
    
    enum TransactionType: String, Codable, CaseIterable {
        case expense = "Expense"
        case income = "Income"
        
        var id: String { rawValue }
    }
}

@Model
final class Category {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String // hex color
    var isDefault: Bool
    
    @Relationship(inverse: \Transaction.category)
    var transactions: [Transaction]
    
    // Non-persisted computed color derived from hex
    var color: Color { Color(hex: colorHex) ?? .gray }
    
    init(name: String, icon: String, colorHex: String, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isDefault = isDefault
        self.transactions = []
    }
    
    static let defaultCategories: [Category] = [
        Category(name: "Food", icon: "fork.knife", colorHex: "#FF3B30", isDefault: true),
        Category(name: "Transport", icon: "car.fill", colorHex: "#AF52DE", isDefault: true),
        Category(name: "Shopping", icon: "bag.fill", colorHex: "#A2845E", isDefault: true),
        Category(name: "Entertainment", icon: "film.fill", colorHex: "#8E8E93", isDefault: true),
        Category(name: "Bills", icon: "doc.text.fill", colorHex: "#FFCC00", isDefault: true),
        Category(name: "Health", icon: "cross.case.fill", colorHex: "#34C759", isDefault: true),
        Category(name: "Other", icon: "ellipsis.circle.fill", colorHex: "#007AFF", isDefault: true)
    ]
}

@Model
final class Subscription {
    var id: UUID
    var name: String
    var amount: Decimal
    var frequency: BillingFrequency
    var nextDueDate: Date
    var category: Category?
    var isActive: Bool
    var notes: String?
    
    init(name: String, amount: Decimal, frequency: BillingFrequency, nextDueDate: Date, category: Category? = nil, isActive: Bool, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.frequency = frequency
        self.nextDueDate = nextDueDate
        self.category = category
        self.isActive = isActive
        self.notes = notes
    }
    
    enum BillingFrequency: String, Codable, CaseIterable, Identifiable {
        case never = "Never"
        case daily = "Daily"
        case weekly = "Weekly"
        case biWeekly = "Bi-Weekly"
        case monthly = "Monthly"
        case semiAnnually = "Semi-Annually"
        case yearly = "Yearly"
        
        var multiplier: Decimal {
            switch self {
                case .never: return 0
                case .daily: return 365
                case .weekly: return 52
                case .biWeekly: return 26
                case .monthly: return 12
                case .semiAnnually: return 2
                case .yearly: return 1
            }
        }

        var id : String {
            return rawValue
        }
    }
    
    var annualAmount: Decimal {
        return amount * frequency.multiplier
    }
    
    var monthlyAmount: Decimal {
        return annualAmount / 12
    }
    
    static func nextDate(for type: BillingFrequency, from date: Date) -> Date {
        switch type {
            case .daily: return Calendar.current.date(byAdding: .day, value: 1, to: date)!
            case .weekly: return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: date)!
            case .biWeekly: return Calendar.current.date(byAdding: .weekOfYear, value: 2, to: date)!
            case .monthly: return Calendar.current.date(byAdding: .month, value: 1, to: date)!
            case .semiAnnually: return Calendar.current.date(byAdding: .month, value: 6, to: date)!
            case .yearly: return Calendar.current.date(byAdding: .year, value: 1, to: date)!
            case .never: return date
       
        }
    }
}

@Model
final class Budget {
    var id: UUID
    var month: Date
    var limit: Decimal
    var category: Category?
    
    init(month: Date, limit: Decimal, category: Category? = nil) {
        self.id = UUID()
        self.month = month
        self.limit = limit
        self.category = category
    }
}


extension Transaction {
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter.string(from: amount as NSDecimalNumber) ?? "€0.00"
    }
    
    var displayAmount: String {
        let sign = type == .expense ? "-" : "+"
        return sign + formattedAmount
    }
}

extension Date {
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }
    
    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? self
    }
}

private extension Color {
    init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        guard hexString.count == 6 || hexString.count == 8 else { return nil }
        var rgba: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&rgba) else { return nil }
        let r, g, b, a: Double
        if hexString.count == 6 {
            r = Double((rgba & 0xFF0000) >> 16) / 255.0
            g = Double((rgba & 0x00FF00) >> 8) / 255.0
            b = Double(rgba & 0x0000FF) / 255.0
            a = 1.0
        } else {
            r = Double((rgba & 0xFF000000) >> 24) / 255.0
            g = Double((rgba & 0x00FF0000) >> 16) / 255.0
            b = Double((rgba & 0x0000FF00) >> 8) / 255.0
            a = Double(rgba & 0x000000FF) / 255.0
        }
        self = Color(red: r, green: g, blue: b, opacity: a)
    }
}
