//
//  MedicationWidget.swift
//  MedCabinetWidgetExtension
//
//  Created on 2026-03-14.
//

import WidgetKit
import SwiftUI

// MARK: - Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MedicationEntry {
        MedicationEntry(
            date: Date(),
            expiringSoonCount: 3,
            expiredCount: 1,
            lowStockCount: 2,
            medications: [
                WidgetMedication(
                    id: UUID(),
                    name: "Tylenol",
                    category: "Pain Relief",
                    quantity: 15,
                    daysUntilExpiry: 5,
                    isExpired: false,
                    needsRestock: true,
                    isPrescription: false
                ),
                WidgetMedication(
                    id: UUID(),
                    name: "Amoxicillin",
                    category: "Antibiotics",
                    quantity: 8,
                    daysUntilExpiry: 2,
                    isExpired: false,
                    needsRestock: false,
                    isPrescription: true
                )
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MedicationEntry) -> ()) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = loadEntry()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    private func loadEntry() -> MedicationEntry {
        guard let data = WidgetDataManager.shared.loadWidgetData() else {
            return MedicationEntry(
                date: Date(),
                expiringSoonCount: 0,
                expiredCount: 0,
                lowStockCount: 0,
                medications: []
            )
        }
        
        return MedicationEntry(
            date: data.lastUpdated,
            expiringSoonCount: data.expiringSoonCount,
            expiredCount: data.expiredCount,
            lowStockCount: data.lowStockCount,
            medications: Array(data.medications.prefix(5))
        )
    }
}

// MARK: - Entry

struct MedicationEntry: TimelineEntry {
    let date: Date
    let expiringSoonCount: Int
    let expiredCount: Int
    let lowStockCount: Int
    let medications: [WidgetMedication]
}

// MARK: - Widget Views

struct MedCabinetWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: MedicationEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "pills.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Spacer()
            }
            
            // Summary Stats
            VStack(alignment: .leading, spacing: 8) {
                if entry.expiredCount > 0 {
                    StatusRow(
                        icon: "exclamationmark.circle.fill",
                        color: .red,
                        text: "\(entry.expiredCount) Expired",
                        count: entry.expiredCount
                    )
                }
                
                if entry.expiringSoonCount > 0 {
                    StatusRow(
                        icon: "clock.fill",
                        color: .orange,
                        text: "\(entry.expiringSoonCount) Expiring Soon",
                        count: entry.expiringSoonCount
                    )
                }
                
                if entry.lowStockCount > 0 {
                    StatusRow(
                        icon: "exclamationmark.triangle.fill",
                        color: .yellow,
                        text: "\(entry.lowStockCount) Low Stock",
                        count: entry.lowStockCount
                    )
                }
                
                if entry.expiredCount == 0 && entry.expiringSoonCount == 0 && entry.lowStockCount == 0 {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("All Good!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Last Updated
            Text("Updated \(entry.date, style: .time)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: MedicationEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left: Summary
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "pills.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("MedCabinet")
                        .font(.headline)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    StatusRow(
                        icon: "exclamationmark.circle.fill",
                        color: .red,
                        text: "Expired",
                        count: entry.expiredCount
                    )
                    StatusRow(
                        icon: "clock.fill",
                        color: .orange,
                        text: "Expiring Soon",
                        count: entry.expiringSoonCount
                    )
                    StatusRow(
                        icon: "exclamationmark.triangle.fill",
                        color: .yellow,
                        text: "Low Stock",
                        count: entry.lowStockCount
                    )
                }
                
                Spacer()
                
                Text("Updated \(entry.date, style: .time)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 120)
            
            Divider()
            
            // Right: Medication List
            VStack(alignment: .leading, spacing: 8) {
                if entry.medications.isEmpty {
                    Text("No medications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ForEach(entry.medications.prefix(3)) { med in
                        MedicationRow(medication: med)
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let entry: MedicationEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "pills.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("MedCabinet")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Text("Updated \(entry.date, style: .time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Stats Row
            HStack(spacing: 16) {
                StatBox(
                    icon: "exclamationmark.circle.fill",
                    color: .red,
                    count: entry.expiredCount,
                    label: "Expired"
                )
                StatBox(
                    icon: "clock.fill",
                    color: .orange,
                    count: entry.expiringSoonCount,
                    label: "Expiring Soon"
                )
                StatBox(
                    icon: "exclamationmark.triangle.fill",
                    color: .yellow,
                    count: entry.lowStockCount,
                    label: "Low Stock"
                )
            }
            
            Divider()
            
            // Medication List
            VStack(alignment: .leading, spacing: 8) {
                Text("Upcoming Expirations")
                    .font(.headline)
                
                if entry.medications.isEmpty {
                    Text("No medications to display")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else {
                    ForEach(entry.medications.prefix(5)) { med in
                        MedicationRow(medication: med)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Helper Views

struct StatusRow: View {
    let icon: String
    let color: Color
    let text: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
            Spacer()
            if count > 0 {
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
        }
    }
}

struct StatBox: View {
    let icon: String
    let color: Color
    let count: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct MedicationRow: View {
    let medication: WidgetMedication
    
    var body: some View {
        HStack(spacing: 8) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(medication.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    if medication.isPrescription {
                        Text("Rx")
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(4)
                    }
                }
                
                Text(medication.displayExpiry)
                    .font(.caption2)
                    .foregroundColor(statusColor)
            }
            
            Spacer()
            
            if medication.needsRestock {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        if medication.isExpired {
            return .red
        } else if medication.daysUntilExpiry <= 7 {
            return .orange
        } else if medication.daysUntilExpiry <= 30 {
            return .yellow
        } else {
            return .green
        }
    }
}

// MARK: - Widget Configuration

struct MedCabinetWidget: Widget {
    let kind: String = "MedCabinetWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MedCabinetWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MedCabinet")
        .description("Track your medication expiration dates and stock levels.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview

struct MedCabinetWidget_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEntry = MedicationEntry(
            date: Date(),
            expiringSoonCount: 3,
            expiredCount: 1,
            lowStockCount: 2,
            medications: [
                WidgetMedication(
                    id: UUID(),
                    name: "Tylenol",
                    category: "Pain Relief",
                    quantity: 15,
                    daysUntilExpiry: 5,
                    isExpired: false,
                    needsRestock: true,
                    isPrescription: false
                ),
                WidgetMedication(
                    id: UUID(),
                    name: "Amoxicillin",
                    category: "Antibiotics",
                    quantity: 8,
                    daysUntilExpiry: 2,
                    isExpired: false,
                    needsRestock: false,
                    isPrescription: true
                ),
                WidgetMedication(
                    id: UUID(),
                    name: "Vitamin D",
                    category: "Supplements",
                    quantity: 45,
                    daysUntilExpiry: 45,
                    isExpired: false,
                    needsRestock: false,
                    isPrescription: false
                )
            ]
        )
        
        Group {
            MedCabinetWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            MedCabinetWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            MedCabinetWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
