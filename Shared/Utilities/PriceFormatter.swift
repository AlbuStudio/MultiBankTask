//
//  PriceFormatter.swift
//  MultiBankTask
//
//  Created by Alexey Bulatnikov on 3/1/26
//

import Foundation

enum PriceFormatter {
    static func price(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: value)) ?? "$\(String(format: "%.2f", value))"
    }
    
    // Change formatter for large numbers
    static func shortChange(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        let absValue = abs(value)
        
        if absValue >= 1_000_000 {
            return "\(sign)\(String(format: "%.1fM", absValue / 1_000_000))"
        } else if absValue >= 1_000 {
            return "\(sign)\(String(format: "%.1fK", absValue / 1_000))"
        } else {
            return "\(sign)\(String(format: "%.2f", absValue))"
        }
    }
    
    // Percentage formatter
    static func shortPercent(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        let absValue = abs(value)
        
        if absValue >= 100 {
            return "\(sign)\(String(format: "%.0f", absValue))%"
        } else if absValue >= 10 {
            return "\(sign)\(String(format: "%.1f", absValue))%"
        } else {
            return "\(sign)\(String(format: "%.2f", absValue))%"
        }
    }

    static func change(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value))"
    }

    static func percent(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value))%"
    }
}
