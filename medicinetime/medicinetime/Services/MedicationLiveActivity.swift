//
//  MedicationLiveActivity.swift
//  medicinetime
//
//  Created on 2026-03-14.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes

struct MedicationReminderAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var medicationName: String
        var dosage: String
        var timeRemaining: TimeInterval
        var isOverdue: Bool
    }
    
    var medicationID: String
    var medicationName: String
    var scheduledTime: Date
}

// MARK: - Live Activity Manager

@available(iOS 16.1, *)
class MedicationLiveActivityManager {
    static let shared = MedicationLiveActivityManager()
    
    private init() {}
    
    // MARK: - Start Live Activity
    
    func startLiveActivity(for medication: Medication, dosage: String, scheduledTime: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        let attributes = MedicationReminderAttributes(
            medicationID: medication.id?.uuidString ?? UUID().uuidString,
            medicationName: medication.displayName,
            scheduledTime: scheduledTime
        )
        
        let initialState = MedicationReminderAttributes.ContentState(
            medicationName: medication.displayName,
            dosage: dosage,
            timeRemaining: scheduledTime.timeIntervalSince(Date()),
            isOverdue: false
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil
            )
            print("Started Live Activity: \(activity.id)")
        } catch {
            print("Error starting Live Activity: \(error)")
        }
    }
    
    // MARK: - Update Live Activity
    
    func updateLiveActivity(activityID: String, timeRemaining: TimeInterval, isOverdue: Bool) {
        Task {
            let updatedState = MedicationReminderAttributes.ContentState(
                medicationName: "",
                dosage: "",
                timeRemaining: timeRemaining,
                isOverdue: isOverdue
            )
            
            for activity in Activity<MedicationReminderAttributes>.activities {
                if activity.id == activityID {
                    await activity.update(using: updatedState)
                    break
                }
            }
        }
    }
    
    // MARK: - End Live Activity
    
    func endLiveActivity(activityID: String) {
        Task {
            for activity in Activity<MedicationReminderAttributes>.activities {
                if activity.id == activityID {
                    await activity.end(dismissalPolicy: .default)
                    break
                }
            }
        }
    }
    
    // MARK: - End All Activities
    
    func endAllActivities() {
        Task {
            for activity in Activity<MedicationReminderAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
}

// MARK: - Live Activity Widget View

@available(iOS 16.1, *)
struct MedicationLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MedicationReminderAttributes.self) { context in
            // Lock Screen / Banner View
            MedicationLiveActivityView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island View
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "pill.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isOverdue {
                        Text("OVERDUE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    } else {
                        Text(formatTimeRemaining(context.state.timeRemaining))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text(context.attributes.medicationName)
                            .font(.headline)
                            .lineLimit(1)
                        
                        if !context.state.dosage.isEmpty {
                            Text(context.state.dosage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 20) {
                        Button(action: {}) {
                            Label("Taken", systemImage: "checkmark.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        
                        Button(action: {}) {
                            Label("Skip", systemImage: "xmark.circle.fill")
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
            } compactLeading: {
                // Compact Leading
                Image(systemName: "pill.fill")
                    .foregroundColor(.white)
            } compactTrailing: {
                // Compact Trailing
                if context.state.isOverdue {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                } else {
                    Text(formatTimeRemainingShort(context.state.timeRemaining))
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            } minimal: {
                // Minimal View
                Image(systemName: "pill.fill")
                    .foregroundColor(context.state.isOverdue ? .red : .white)
            }
        }
    }
    
    private func formatTimeRemaining(_ interval: TimeInterval) -> String {
        if interval <= 0 {
            return "Overdue"
        }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatTimeRemainingShort(_ interval: TimeInterval) -> String {
        if interval <= 0 {
            return "!"
        }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Live Activity View

@available(iOS 16.1, *)
struct MedicationLiveActivityView: View {
    let context: ActivityViewContext<MedicationReminderAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "pill.fill")
                    .font(.title)
                    .foregroundColor(.appPrimary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.medicationName)
                        .font(.headline)
                    
                    if !context.state.dosage.isEmpty {
                        Text(context.state.dosage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if context.state.isOverdue {
                    VStack(alignment: .trailing) {
                        Text("OVERDUE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text(formatTimeRemaining(abs(context.state.timeRemaining)) + " ago")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(alignment: .trailing) {
                        Text("In")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatTimeRemaining(context.state.timeRemaining))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.appPrimary)
                    }
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(context.state.isOverdue ? Color.red : Color.appPrimary)
                        .frame(width: progressWidth(in: geometry.size.width), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            // Action Buttons
            HStack(spacing: 16) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Mark as Taken")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Skip")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func progressWidth(in totalWidth: CGFloat) -> CGFloat {
        let totalDuration: TimeInterval = 3600 // 1 hour default
        let elapsed = totalDuration - max(0, context.state.timeRemaining)
        let progress = min(1.0, max(0.0, elapsed / totalDuration))
        return totalWidth * CGFloat(progress)
    }
    
    private func formatTimeRemaining(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Preview

@available(iOS 16.1, *)
struct MedicationLiveActivityWidget_Previews: PreviewProvider {
    static var previews: some View {
        Text("Live Activity Preview")
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
