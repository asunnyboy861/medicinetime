//
//  DashboardEmptyStateView.swift
//  medicinetime
//
//  Created on 2026-03-14.
//

import SwiftUI

struct DashboardEmptyStateView: View {
    @Binding var showAddMedication: Bool
    @Binding var showScanner: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Illustration
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                VStack(spacing: -10) {
                    Image(systemName: "pills.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.appPrimary)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.appSuccess)
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: 25, y: -5)
                }
            }
            
            // Text content
            VStack(spacing: 12) {
                Text("Start Your Medicine Cabinet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Keep track of your medications, expiration dates, and stock levels all in one place.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Action buttons
            VStack(spacing: 16) {
                Button(action: { showAddMedication = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add First Medication")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appPrimary)
                    .cornerRadius(12)
                }
                
                Button(action: { showScanner = true }) {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Text("Scan Barcode")
                    }
                    .font(.subheadline)
                    .foregroundColor(.appPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.appPrimary.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 32)
            
            // Features preview
            VStack(spacing: 12) {
                FeatureRow(icon: "clock.fill", text: "Expiry date tracking")
                FeatureRow(icon: "bell.fill", text: "Smart refill reminders")
                FeatureRow(icon: "lock.fill", text: "Private & secure")
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.appPrimary)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 60)
    }
}

// MARK: - Preview
struct DashboardEmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardEmptyStateView(
            showAddMedication: .constant(false),
            showScanner: .constant(false)
        )
    }
}
