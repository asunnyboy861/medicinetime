//
//  ContentView.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var persistenceController: PersistenceController
    @EnvironmentObject var notificationManager: NotificationManager
    @ObservedObject var viewModel: MedicationViewModel
    
    @State private var selectedTab = 0
    @Binding var shortcutAction: ShortcutAction?
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainContent
            } else {
                OnboardingView(showAddMedication: $viewModel.showingAddMedication)
                    .environmentObject(viewModel)
            }
        }
    }
    
    private var mainContent: some View {
        TabView(selection: $selectedTab) {
            DashboardView(viewModel: viewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            MedicationListView(viewModel: viewModel)
                .tabItem {
                    Label("Medications", systemImage: "pill.fill")
                }
                .tag(1)
            
            CategoriesView(viewModel: viewModel)
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tabViewStyle(.automatic)
        .onAppear {
            // 强制TabBar在iPad上也显示在底部
            UITabBar.appearance().isTranslucent = false
            UINavigationBar.appearance().isTranslucent = false
            if UIDevice.current.userInterfaceIdiom == .pad {
                UITabBar.appearance().backgroundColor = .systemBackground
            }
        }
        .sheet(isPresented: $viewModel.showingAddMedication) {
            AddMedicationView(viewModel: viewModel)
        }
        .onChange(of: shortcutAction) { oldValue, newValue in
            guard let action = newValue else { return }
            handleShortcutAction(action)
            shortcutAction = nil
        }
        .environmentObject(viewModel)
    }
    
    private func handleShortcutAction(_ action: ShortcutAction) {
        switch action {
        case .addMedication:
            viewModel.showingAddMedication = true
        case .search:
            selectedTab = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.searchText = ""
                // Focus search field
            }
        case .expiringSoon:
            selectedTab = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.selectedCategory = nil
                viewModel.searchText = "expiring"
            }
        case .lowStock:
            selectedTab = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.selectedCategory = nil
                viewModel.searchText = "low stock"
            }
        }
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @ObservedObject var viewModel: MedicationViewModel
    @EnvironmentObject var persistenceController: PersistenceController
    @State private var showScanner = false
    
    var body: some View {
        Group {
            if viewModel.medications.isEmpty {
                DashboardEmptyStateView(
                    showAddMedication: $viewModel.showingAddMedication,
                    showScanner: $showScanner
                )
                .navigationTitle("MedCabinet")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.showingAddMedication = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
            } else {
                dashboardContent
            }
        }
        .sheet(isPresented: $showScanner) {
            BarcodeScannerView { barcode in
                handleScannedBarcode(barcode)
            }
        }
    }
    
    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Statistics Cards
                StatisticsCardsView(viewModel: viewModel)
                
                // Expiring Soon Section
                if viewModel.expiringSoonCount > 0 {
                    ExpiringSoonSection(viewModel: viewModel)
                }
                
                // Low Stock Section
                if viewModel.lowStockCount > 0 {
                    LowStockSection(viewModel: viewModel)
                }
                
                // Restock List Button
                if viewModel.lowStockCount > 0 {
                    NavigationLink {
                        RestockListView(viewModel: viewModel)
                    } label: {
                        HStack {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Restock List")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                Text("\(viewModel.lowStockCount) items need restocking")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding()
                        .background(Color.appWarning)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                // Quick Actions
                QuickActionsView(showingAddMedication: $viewModel.showingAddMedication)
            }
            .padding()
        }
        .navigationTitle("MedCabinet")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.showingAddMedication = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
    }
    
    private func handleScannedBarcode(_ barcode: String) {
        showScanner = false
        viewModel.showingAddMedication = true
        // Barcode will be handled by AddMedicationView
    }
}

// MARK: - Statistics Cards
struct StatisticsCardsView: View {
    @ObservedObject var viewModel: MedicationViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Total",
                value: "\(viewModel.totalMedications)",
                icon: "pill.fill",
                color: .appPrimary
            )
            
            StatCard(
                title: "Expiring",
                value: "\(viewModel.expiringSoonCount)",
                icon: "clock.fill",
                color: .appWarning
            )
            
            StatCard(
                title: "Low Stock",
                value: "\(viewModel.lowStockCount)",
                icon: "exclamationmark.triangle.fill",
                color: .appError
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Expiring Soon Section
struct ExpiringSoonSection: View {
    @ObservedObject var viewModel: MedicationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Expiring Soon")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink("See All") {
                    MedicationListView(viewModel: viewModel)
                }
                .font(.subheadline)
            }
            
            ForEach(viewModel.medications.filter { $0.expiryStatus == .expiringSoon || $0.expiryStatus == .expiringIn3Months }.prefix(3)) { medication in
                MedicationCard(medication: medication)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Low Stock Section
struct LowStockSection: View {
    @ObservedObject var viewModel: MedicationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Low Stock")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink("See All") {
                    MedicationListView(viewModel: viewModel)
                }
                .font(.subheadline)
            }
            
            ForEach(viewModel.medications.filter { $0.needsRestock }.prefix(3)) { medication in
                MedicationCard(medication: medication)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Quick Actions
struct QuickActionsView: View {
    @Binding var showingAddMedication: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Add Medication",
                    icon: "plus.circle.fill",
                    color: .appPrimary
                ) {
                    showingAddMedication = true
                }
                
                QuickActionButton(
                    title: "Scan Barcode",
                    icon: "barcode.viewfinder",
                    color: .appSecondary
                ) {
                    // TODO: Open barcode scanner
                }
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistence = PersistenceController.preview
        let viewModel = MedicationViewModel(persistenceController: persistence)
        ContentView(viewModel: viewModel, shortcutAction: .constant(nil))
            .environmentObject(persistence)
            .environment(\.managedObjectContext, persistence.container.viewContext)
    }
}
