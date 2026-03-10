//
//  CategoriesView.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import SwiftUI

struct CategoriesView: View {
    @ObservedObject var viewModel: MedicationViewModel
    @State private var showingAddCategory = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.categories) { category in
                    NavigationLink(destination: CategoryDetailView(category: category, viewModel: viewModel)) {
                        HStack(spacing: 16) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(category.uiColor.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: category.icon)
                                    .font(.title2)
                                    .foregroundColor(category.uiColor)
                            }
                            
                            // Info
                            VStack(alignment: .leading, spacing: 4) {
                                Text(category.name)
                                    .font(.headline)
                                
                                Text("\(category.medicationCount) medications")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Arrow
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .onDelete(perform: deleteCategory)
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCategory = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(viewModel: viewModel)
            }
        }
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        // TODO: Delete category logic
    }
}

// MARK: - Category Detail View
struct CategoryDetailView: View {
    let category: Category
    let viewModel: MedicationViewModel
    
    var body: some View {
        List {
            Section("Category Info") {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(category.name)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Icon")
                    Spacer()
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundColor(category.uiColor)
                }
                
                HStack {
                    Text("Color")
                    Spacer()
                    Circle()
                        .fill(category.uiColor)
                        .frame(width: 24, height: 24)
                }
            }
            
            Section("Medications") {
                ForEach(viewModel.medications.filter { $0.category == category.name }) { medication in
                    NavigationLink(destination: MedicationDetailView(medication: medication)) {
                        MedicationCard(medication: medication)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                    }
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Add Category View
struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MedicationViewModel
    
    @State private var name = ""
    @State private var selectedIcon = "pill.fill"
    @State private var selectedColor = "FF6B6B"
    
    let icons = ["pill.fill", "thermometer.sun.fill", "wind", "drop.fill", "cross.fill", "heart.fill", "hand.raised.fill", "eye.fill"]
    let colors = ["FF6B6B", "4ECDC4", "45B7D1", "96CEB4", "FFEEAD", "FF9FF3", "D4A5A5", "9B59B6"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Category Name") {
                    TextField("Enter category name", text: $name)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .appPrimary : .secondary)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(selectedIcon == icon ? Color.appPrimary.opacity(0.1) : Color.clear)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCategory()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCategory() {
        // TODO: Save category to Core Data
    }
}

// MARK: - Preview
struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView(viewModel: MedicationViewModel(persistenceController: .preview))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
