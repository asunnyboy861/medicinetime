//
//  OnboardingView.swift
//  medicinetime
//
//  Created on 2026-03-14.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @Binding var showAddMedication: Bool
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to MedCabinet",
            description: "Your personal medication manager. Track expiration dates, monitor stock levels, and never miss a refill.",
            icon: "pills.fill",
            color: .appPrimary
        ),
        OnboardingPage(
            title: "Easy Medication Entry",
            description: "Scan barcodes for instant medication lookup, or manually enter details. It's quick and simple.",
            icon: "barcode.viewfinder",
            color: .appSuccess
        ),
        OnboardingPage(
            title: "Smart Expiry Alerts",
            description: "Get notified before medications expire. We'll remind you at 3 months, 1 month, and 1 week before expiration.",
            icon: "bell.badge.fill",
            color: .appWarning
        ),
        OnboardingPage(
            title: "Ready to Start?",
            description: "Add your first medication to begin tracking your medicine cabinet.",
            icon: "plus.circle.fill",
            color: .appPrimary,
            isLastPage: true
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                Button("Skip") {
                    completeOnboarding()
                }
                .foregroundColor(.secondary)
                .padding()
            }
            
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(currentPage == index ? pages[currentPage].color : Color.secondary.opacity(0.3))
                        .frame(width: currentPage == index ? 20 : 8, height: 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.bottom, 20)
            
            // Navigation buttons
            HStack(spacing: 20) {
                if currentPage > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                    if currentPage == pages.count - 1 {
                        completeOnboarding()
                        showAddMedication = true
                    } else {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

// MARK: - Data Model
struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let color: Color
    var isLastPage: Bool = false
}

// MARK: - Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 180, height: 180)
                
                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundColor(page.color)
            }
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showAddMedication: .constant(false))
    }
}
