//
//  BarcodeService.swift
//  medicinetime
//
//  Created on 2026-03-14.
//

import Foundation

struct BarcodeResult {
    let barcode: String
    let name: String?
    let category: String?
    let dosage: String?
    let manufacturer: String?
    let confidence: Confidence
    
    enum Confidence {
        case high
        case medium
        case low
    }
}

struct MedicationBarcodeInfo: Codable {
    let name: String
    let category: String
    let dosage: String?
    let manufacturer: String?
    let barcodes: [String]
}

final class BarcodeService {
    static let shared = BarcodeService()
    
    private var barcodeDatabase: [String: MedicationBarcodeInfo] = [:]
    
    private init() {
        loadBarcodeDatabase()
    }
    
    private func loadBarcodeDatabase() {
        guard let url = Bundle.main.url(forResource: "MedicationBarcodes", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Warning: MedicationBarcodes.json not found, using empty database")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let barcodes = try decoder.decode([MedicationBarcodeInfo].self, from: data)
            barcodes.forEach { info in
                info.barcodes.forEach { barcode in
                    barcodeDatabase[barcode] = info
                }
            }
            print("Loaded \(barcodeDatabase.count) barcode entries")
        } catch {
            print("Error loading barcode database: \(error)")
        }
    }
    
    func lookup(barcode: String) -> BarcodeResult {
        if let info = barcodeDatabase[barcode] {
            return BarcodeResult(
                barcode: barcode,
                name: info.name,
                category: info.category,
                dosage: info.dosage,
                manufacturer: info.manufacturer,
                confidence: .high
            )
        }
        
        return BarcodeResult(
            barcode: barcode,
            name: nil,
            category: nil,
            dosage: nil,
            manufacturer: nil,
            confidence: .low
        )
    }
}
