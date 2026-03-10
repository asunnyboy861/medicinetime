//
//  Array+Safe.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Date Extensions
extension Date {
    func addingDays(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func addingMonths(_ months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
}

// MARK: - String Extensions
extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func toUUID() -> UUID? {
        return UUID(uuidString: self)
    }
}

// MARK: - Int Extensions
extension Int {
    var daysToSeconds: TimeInterval {
        return TimeInterval(self) * 86400
    }
    
    var monthsToDays: Int {
        return self * 30
    }
}

// MARK: - Optional Extensions
extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self == nil || self?.isEmpty == true
    }
}
