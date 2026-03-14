//
//  ExportService.swift
//  medicinetime
//
//  Created on 2026-03-14.
//

import Foundation
import PDFKit
import UIKit

final class ExportService {
    static let shared = ExportService()
    
    private init() {}
    
    // MARK: - CSV Export
    
    func exportToCSV(medications: [Medication]) -> URL? {
        let csvHeader = "Name,Category,Quantity,Unit,Expiration Date,Status,Location,Notes\n"
        let csvRows = medications.map { med in
            [
                med.displayName.csvEscaped,
                med.displayCategory.csvEscaped,
                "\(med.quantity)",
                med.displayUnit.csvEscaped,
                formatDate(med.safeExpirationDate),
                med.expiryStatus.label,
                med.displayLocation.csvEscaped,
                med.displayNotes.csvEscaped
            ].joined(separator: ",")
        }
        
        let csvContent = csvHeader + csvRows.joined(separator: "\n")
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("medications.csv")
        do {
            try csvContent.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("Error exporting CSV: \(error)")
            return nil
        }
    }
    
    // MARK: - PDF Export
    
    func exportToPDF(medications: [Medication]) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "MedCabinet",
            kCGPDFContextAuthor: "MedCabinet App"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("medications.pdf")
        
        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                
                var y: CGFloat = 50
                
                // Title
                let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
                let titleAttrs: [NSAttributedString.Key: Any] = [
                    .font: titleFont,
                    .foregroundColor: UIColor.systemBlue
                ]
                let title = "Medication Inventory Report"
                title.draw(at: CGPoint(x: 50, y: y), withAttributes: titleAttrs)
                y += 40
                
                // Date
                let dateFont = UIFont.systemFont(ofSize: 12)
                let dateAttrs: [NSAttributedString.Key: Any] = [
                    .font: dateFont,
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                let dateStr = "Generated: \(dateFormatter.string(from: Date()))"
                dateStr.draw(at: CGPoint(x: 50, y: y), withAttributes: dateAttrs)
                y += 30
                
                // Summary
                let summaryFont = UIFont.systemFont(ofSize: 14)
                let summaryAttrs: [NSAttributedString.Key: Any] = [
                    .font: summaryFont,
                    .foregroundColor: UIColor.label
                ]
                let summary = "Total: \(medications.count) medications"
                summary.draw(at: CGPoint(x: 50, y: y), withAttributes: summaryAttrs)
                y += 40
                
                // Medications
                let headerFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
                let contentFont = UIFont.systemFont(ofSize: 11)
                
                for medication in medications {
                    if y > 750 {
                        context.beginPage()
                        y = 50
                    }
                    
                    // Name
                    let nameAttrs: [NSAttributedString.Key: Any] = [
                        .font: headerFont,
                        .foregroundColor: UIColor.label
                    ]
                    medication.displayName.draw(at: CGPoint(x: 50, y: y), withAttributes: nameAttrs)
                    y += 20
                    
                    // Details
                    let detailsAttrs: [NSAttributedString.Key: Any] = [
                        .font: contentFont,
                        .foregroundColor: UIColor.secondaryLabel
                    ]
                    let details = "Qty: \(medication.quantity) \(medication.displayUnit) | Expires: \(formatDate(medication.safeExpirationDate)) | Status: \(medication.expiryStatus.label)"
                    details.draw(at: CGPoint(x: 70, y: y), withAttributes: detailsAttrs)
                    y += 25
                    
                    if !medication.displayLocation.isEmpty {
                        let location = "Location: \(medication.displayLocation)"
                        location.draw(at: CGPoint(x: 70, y: y), withAttributes: detailsAttrs)
                        y += 20
                    }
                    
                    y += 10
                }
            }
            
            return url
        } catch {
            print("Error exporting PDF: \(error)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - String Extension

extension String {
    var csvEscaped: String {
        if self.contains(",") || self.contains("\"") || self.contains("\n") {
            return "\"\(self.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return self
    }
}
