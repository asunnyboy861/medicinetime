//
//  FeedbackView.swift
//  medicinetime
//
//  Contact Support - User Feedback Form
//  Created on 2026-03-14.
//

import SwiftUI

// MARK: - Feedback Topic
enum FeedbackTopic: String, CaseIterable, Identifiable {
    case bugReport = "Bug Report"
    case featureRequest = "Feature Request"
    case generalFeedback = "General Feedback"
    case dataIssue = "Data Issue"
    case performance = "Performance Issue"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .bugReport: return "ladybug.fill"
        case .featureRequest: return "lightbulb.fill"
        case .generalFeedback: return "message.fill"
        case .dataIssue: return "exclamationmark.triangle.fill"
        case .performance: return "gauge.with.dots.needle.67percent"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bugReport: return .red
        case .featureRequest: return .yellow
        case .generalFeedback: return .blue
        case .dataIssue: return .orange
        case .performance: return .purple
        case .other: return .gray
        }
    }
    
    var description: String {
        switch self {
        case .bugReport: return "Report a problem or unexpected behavior"
        case .featureRequest: return "Suggest a new feature or improvement"
        case .generalFeedback: return "Share your thoughts about the app"
        case .dataIssue: return "Issues with medication data or sync"
        case .performance: return "App running slowly or crashing"
        case .other: return "Something else not listed above"
        }
    }
}

// MARK: - Feedback View Model
@MainActor
class FeedbackViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var message = ""
    @Published var selectedTopic: FeedbackTopic = .generalFeedback
    @Published var isSubmitting = false
    @Published var showSuccess = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let feedbackURL = "https://feedback-board.iocompile67692.workers.dev/api/feedback"
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func submitFeedback() async {
        guard isValid else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        let feedbackData: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespaces),
            "email": email.trimmingCharacters(in: .whitespaces),
            "subject": selectedTopic.rawValue,
            "message": message.trimmingCharacters(in: .whitespaces),
            "app_name": "MedCabinet"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: feedbackData)
            
            guard let url = URL(string: feedbackURL) else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 30
            request.httpBody = jsonData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                showSuccess = true
                clearForm()
            } else {
                throw NSError(domain: "FeedbackError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"])
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isSubmitting = false
    }
    
    func clearForm() {
        name = ""
        email = ""
        message = ""
        selectedTopic = .generalFeedback
    }
}

// MARK: - Feedback View
struct FeedbackView: View {
    @StateObject private var viewModel = FeedbackViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Topic Selection Section
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(FeedbackTopic.allCases) { topic in
                                TopicCard(
                                    topic: topic,
                                    isSelected: viewModel.selectedTopic == topic
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        viewModel.selectedTopic = topic
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Select Topic")
                        .font(.headline)
                        .textCase(nil)
                }
                
                // Contact Information Section
                Section(header: Text("Contact Information")) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.appPrimary)
                            .frame(width: 24)
                        
                        TextField("Your Name", text: $viewModel.name)
                            .textContentType(.name)
                            .autocapitalization(.words)
                    }
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.appPrimary)
                            .frame(width: 24)
                        
                        TextField("Email Address", text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                    }
                }
                
                // Message Section
                Section(header: Text("Your Feedback")) {
                    ZStack(alignment: .topLeading) {
                        if viewModel.message.isEmpty {
                            Text("Describe your feedback in detail...\n\nFor bug reports: Please include steps to reproduce\nFor feature requests: Please describe the desired behavior")
                                .foregroundColor(.secondary.opacity(0.6))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $viewModel.message)
                            .frame(minHeight: 120)
                            .padding(.horizontal, -4)
                    }
                }
                
                // Submit Button Section
                Section {
                    Button(action: {
                        Task {
                            await viewModel.submitFeedback()
                        }
                    }) {
                        HStack {
                            Spacer()
                            
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "paperplane.fill")
                                Text("Submit Feedback")
                            }
                            
                            Spacer()
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isSubmitting)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                
                // Privacy Note
                Section {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                        
                        Text("Your feedback is securely transmitted and stored. We only use your email to respond to your inquiry.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Thank You!", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your feedback has been submitted successfully. We'll review it and get back to you soon.")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.showError = false
                }
                Button("Try Again") {
                    Task {
                        await viewModel.submitFeedback()
                    }
                }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred while submitting your feedback. Please check your internet connection and try again.")
            }
        }
    }
}

// MARK: - Topic Card Component
struct TopicCard: View {
    let topic: FeedbackTopic
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: topic.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : topic.color)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                
                Text(topic.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                
                Text(topic.description)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(12)
            .frame(width: 160, height: 110, alignment: .topLeading)
            .background(isSelected ? topic.color : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? topic.color : Color(.separator), lineWidth: isSelected ? 0 : 1)
            )
            .shadow(color: isSelected ? topic.color.opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 8 : 2, x: 0, y: isSelected ? 4 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
