import SwiftUI
import SwiftData

struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Provide an explicit sort so the @Query generic can be inferred correctly
    @Query(sort: \Category.name) private var categories: [Category]

    @Binding var selected: Category?
    @State private var isPresentingCreate = false
    @State private var isPresentingHandle = false

    var body: some View {
        List {
            Section {
                Button {
                    selected = nil
                    dismiss()
                } label: {
                    HStack {
                        Text("Nessuna")
                        if selected == nil {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                
                ForEach(categories) { category in
                    Button {
                        selected = category
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill((category.color).opacity(0.15))
                                    .frame(width: 35, height: 35)
                                
                                Image(systemName: category.icon)
                                    .foregroundStyle(category.color)
                                    .font(.body)
                            }

                            // Name
                            Text(category.name)
                                .font(.body)
                        }
                    }
                }

                
            } header: {
                Text("Seleziona categoria")
            }
            
            Section {
                Button {
                    isPresentingHandle = true
                } label: {
                    HStack (spacing: 12) {
                        Text("Gestisci Categorie")
                            .font(.body)
                        Image(systemName: "pencil")
                            .foregroundStyle(Color(.systemBlue))
                            .font(.body)
                    }

                }
            }
        }
        .navigationTitle("Categorie")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingCreate = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color(.systemBlue))
                        .font(.body)
                }
            }
        }
        .sheet(isPresented: $isPresentingCreate) {
            NavigationStack {
                CreateCategoryView { newCategory in
                    // Auto-select the newly created category
                    selected = newCategory
                    isPresentingCreate = false
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $isPresentingHandle) {
            NavigationStack {
                HandleCategoriesView()
            }
        }
    }

    // Helper to compare categories without relying on internal IDs that may differ
    private func isSameCategory(_ lhs: Category?, _ rhs: Category) -> Bool {
        guard let lhs else { return false }
        // Prefer comparing a stable identifier if your Category has one, otherwise fallback to object identity
        if let l = lhs as? AnyObject, let r = rhs as? AnyObject {
            return l === r
        }
        // As a fallback, compare names and icons
        return lhs.name == rhs.name && lhs.icon == rhs.icon
    }
}

