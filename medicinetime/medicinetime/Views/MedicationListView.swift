//
//  MedicationListView.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import SwiftUI
import CoreData

struct MedicationListView: View {
    @ObservedObject var viewModel: MedicationViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedMedication: Medication?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText)
                
                // Category Filter
                CategoryFilterView(
                    categories: viewModel.categories,
                    selectedCategory: $viewModel.selectedCategory
                )
                
                // Medication List
                List {
                    if viewModel.filteredMedications.isEmpty {
                        EmptyStateView(
                            title: "No Medications",
                            message: "Tap + to add your first medication",
                            icon: "pill.fill"
                        )
                    } else {
                        ForEach(viewModel.filteredMedications) { medication in
                            NavigationLink(destination: MedicationDetailView(medication: medication)) {
                                MedicationCard(medication: medication)
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteMedications)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Medications")
            .searchable(text: $viewModel.searchText, prompt: "Search medications")
        }
    }
    
    private func deleteMedications(at offsets: IndexSet) {
        for index in offsets {
            let medication = viewModel.filteredMedications[index]
            viewModel.deleteMedication(medication)
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search medications", text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color.appBackground)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Category Filter
struct CategoryFilterView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    color: .appPrimary,
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(categories) { category in
                    CategoryChip(
                        title: category.displayName,
                        icon: category.displayIcon,
                        color: category.displayColor,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : color.opacity(0.1))
            .foregroundColor(isSelected ? .white : color)
            .cornerRadius(20)
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - Preview
struct MedicationListView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationListView(viewModel: MedicationViewModel(persistenceController: .preview))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
