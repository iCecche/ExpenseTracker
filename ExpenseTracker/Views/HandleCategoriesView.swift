import SwiftUI
import SwiftData

struct HandleCategoriesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.name) private var categories: [Category]
    @State private var isPresentingEditor = false
    @State private var categoryBeingEdited: Category? = nil

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories, id: \.id) { category in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(category.color.opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: category.icon)
                                .foregroundStyle(category.color)
                        }
                        .frame(width: 40, height: 40)
                        Text(category.name)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        categoryBeingEdited = category
                        isPresentingEditor = true
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(categories[index])
                    }
                    do { try modelContext.save() } catch { }
                }
            }
            .navigationTitle("Categorie")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Nuova Categoria") {
                        categoryBeingEdited = nil
                        isPresentingEditor = true
                    }
                }
            }
            .sheet(isPresented: $isPresentingEditor) {
                NavigationStack {
                    Editor(existing: categoryBeingEdited) { _ in
                        isPresentingEditor = false
                    }
                }
            }
        }
    }

    struct Editor: View {
        @Environment(\.dismiss) private var dismiss
        @Environment(\.modelContext) private var modelContext

        var existing: Category?
        var onComplete: (Category) -> Void

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
                    Button("Salva") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $isShowingIconBrowser) {
                NavigationStack {
                    IconBrowserView(selectedIcon: $icon)
                }
            }
            .onAppear {
                name = existing?.name ?? ""
                icon = existing?.icon ?? ""
                color = existing?.color ?? .blue
            }
            .navigationTitle("Nuova Categoria")
            .navigationBarTitleDisplayMode(.inline)
        }


        private func save() {
            if let existing {
                existing.name = name
                existing.colorHex = color.toHexString()
                existing.icon = icon
                do { try modelContext.save() } catch { }
                onComplete(existing)
                dismiss()
            } else {
                let hexColor = color.toHexString()
                let new = Category(name: name, icon: icon, colorHex: hexColor)
                modelContext.insert(new)
                do { try modelContext.save() } catch { }
                onComplete(new)
                dismiss()
            }
        }
    }
}

#Preview {
    HandleCategoriesView()
}
