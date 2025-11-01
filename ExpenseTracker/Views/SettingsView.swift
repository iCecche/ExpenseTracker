//
//  SettingsView.swift
//  ExpenseTracker
//
//  Created by alessio ceccherini on 26/10/25.
//

import Foundation
import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        Text("Budget Settings")
                    } label: {
                        Label("Budget", systemImage: "eurosign.circle")
                    }
                    
                    NavigationLink {
                        Text("Categories")
                    } label: {
                        Label("Categorie", systemImage: "folder")
                    }
                }
                
                Section {
                    NavigationLink {
                        Text("Notifications")
                    } label: {
                        Label("Notifiche", systemImage: "bell")
                    }
                    
                    NavigationLink {
                        Text("iCloud Sync")
                    } label: {
                        Label("Sincronizzazione", systemImage: "icloud")
                    }
                }
                
                Section {
                    NavigationLink {
                        Text("Export Data")
                    } label: {
                        Label("Esporta Dati", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .navigationTitle("Impostazioni")
        }
    }
}
