import SwiftUI
import SwiftData

// MARK: - Icon Browser
public struct IconBrowserView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIcon: String
    @State private var query: String = ""

    // A curated list of SF Symbols; in a real app you might expand this or load dynamically
    public var allSymbols: [String] = {
        let base = [
            "cart", "car", "house", "fork.knife", "creditcard", "gift", "fuelpump", "tram", "airplane", "bicycle", "bus",
            "heart", "stethoscope", "cross.case", "pill",
            "gamecontroller", "tshirt", "shippingbox", "bag", "bag.fill",
            "book", "newspaper", "magazine", "laptopcomputer","camera", "film", "music.note", "music.mic", "headphones",
            "lightbulb", "bolt", "hammer", "wrench.and.screwdriver", "fork.knife.circle", "takeoutbag.and.cup.and.straw",
            "scissors", "paintbrush", "pencil", "map",
        ]
        return base
    }()

    var filteredSymbols: [String] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return allSymbols }
        return allSymbols.filter { $0.contains(q) }
    }

    public let browserColumns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)

    public var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: browserColumns, spacing: 10) {
                    ForEach(filteredSymbols, id: \.self) { symbol in
                        Button {
                            selectedIcon = symbol
                            dismiss()
                        } label: {
                            BrowserIconCell(symbol: symbol, isSelected: selectedIcon == symbol)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
            }
        }
        .navigationTitle("Seleziona icona")
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annulla") { dismiss() }
            }
        }
    }
}

public struct BrowserIconCell: View {
    let symbol: String
    let isSelected: Bool

    public var body: some View {
        VStack(spacing: 6) {
            ZStack {
                let fillColor = isSelected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08)
                let strokeColor = isSelected ? Color.accentColor : Color.clear
                RoundedRectangle(cornerRadius: 10)
                    .fill(fillColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(strokeColor, lineWidth: 2)
                    )
                    .frame(height: 44)
                Image(systemName: symbol)
                    .foregroundStyle(.primary)
            }
            Text(symbol)
                .font(.caption2)
                .lineLimit(1)
                .foregroundStyle(.secondary)
        }
    }
}


struct CreateCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var icon: String = "folder"
    @State private var color: Color = .blue
    @State private var isShowingIconBrowser = false

    private let commonIcons: [String] = [
        "cart", "car", "house", "fork.knife", "creditcard", "gift", "fuelpump", "tram", "airplane",
        "heart", "stethoscope", "gamecontroller", "tshirt", "shippingbox", "book", "laptopcomputer", "camera",
        "film", "music.note", "pawprint", "sparkles", "lightbulb", "leaf", "cup.and.saucer", "scissors"
    ]
    private let quickGridColumns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)

    let onCreated: (Category) -> Void

    var body: some View {
        Form {
            Section("Dettagli") {
                TextField("Nome", text: $name)

                // Icon picker trigger and quick grid
                VStack(alignment: .leading, spacing: 8) {
                    Text("Icona")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    // Quick selection grid of common icons
                    LazyVGrid(columns: quickGridColumns, spacing: 8) {
                        ForEach(commonIcons, id: \.self) { symbol in
                            Button {
                                icon = symbol
                            } label: {
                                IconCell(symbol: symbol, isSelected: icon == symbol)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Button {
                        isShowingIconBrowser = true
                    } label: {
                        Label("Scegli icona", systemImage: "square.grid.3x3")
                    }
                }

                ColorPicker("Colore", selection: $color, supportsOpacity: false)
            }

            Section("Anteprima") {
                Label(name.isEmpty ? "Categoria" : name, systemImage: icon.isEmpty ? "folder" : icon)
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(color)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annulla") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva") { saveCategory() }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .sheet(isPresented: $isShowingIconBrowser) {
            NavigationStack {
                IconBrowserView(selectedIcon: $icon)
            }
        }
        .navigationTitle("Nuova Categoria")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveCategory() {
        let hex = color.toHexString()
        let newCategory = Category(name: name, icon: icon.isEmpty ? "folder" : icon, colorHex: hex)
        modelContext.insert(newCategory)
        onCreated(newCategory)
        dismiss()
    }
}

internal struct IconCell: View {
    let symbol: String
    let isSelected: Bool

    var body: some View {
        ZStack {
            let fillColor = isSelected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08)
            let strokeColor = isSelected ? Color.accentColor : Color.clear
            RoundedRectangle(cornerRadius: 8)
                .fill(fillColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(strokeColor, lineWidth: 2)
                )
            Image(systemName: symbol)
                .foregroundStyle(.primary)
                .frame(width: 28, height: 28)
                .padding(8)
        }
        .accessibilityLabel(Text(symbol))
    }
}

// MARK: - Color <-> Hex helpers
internal extension Color {
    func toHexString() -> String {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        return String(format: "#%06x", rgb)
        #else
        return "#000000"
        #endif
    }
}
