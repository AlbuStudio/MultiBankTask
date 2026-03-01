//
//  Stock.swift
//  MultiBankTask
//
//  Created by Alexey Bulatnikov on 3/1/26.
//

import Foundation

// Represents a stock with its current trading information.
struct Stock: Identifiable, Hashable {
    let id: String // Using symbol as ID since it's unique
    let symbol: String
    let name: String
    var currentPrice: Double
    var previousPrice: Double
    var lastUpdated: Date
    var volume: Int?
    
    init(symbol: String, name: String, currentPrice: Double = 0, previousPrice: Double = 0, lastUpdated: Date = Date(), volume: Int? = nil) {
        self.id = symbol
        self.symbol = symbol
        self.name = name
        self.currentPrice = currentPrice
        self.previousPrice = previousPrice
        self.lastUpdated = lastUpdated
        self.volume = volume
    }
    
    // Price change from previous close
    var priceChange: Double {
        currentPrice - previousPrice
    }
    
    // Percentage change from previous close
    var priceChangePercentage: Double {
        guard previousPrice > 0 else { return 0 }
        return (priceChange / previousPrice) * 100
    }
    
    // Whether the stock price increased.
    var isPriceUp: Bool {
        priceChange >= 0
    }
}

// MARK: - Mock Data for Stocks
extension Stock {
    static let mockStocks: [Stock] = [
        Stock(symbol: "AAPL", name: "Apple Inc."),
        Stock(symbol: "GOOG", name: "Alphabet Inc."),
        Stock(symbol: "TSLA", name: "Tesla Inc."),
        Stock(symbol: "AMZN", name: "Amazon.com Inc."),
        Stock(symbol: "MSFT", name: "Microsoft Corp."),
        Stock(symbol: "NVDA", name: "NVIDIA Corp."),
        Stock(symbol: "META", name: "Meta Platforms Inc."),
        Stock(symbol: "NFLX", name: "Netflix Inc."),
        Stock(symbol: "AMD", name: "Advanced Micro Devices"),
        Stock(symbol: "INTC", name: "Intel Corp."),
        Stock(symbol: "CRM", name: "Salesforce Inc."),
        Stock(symbol: "ORCL", name: "Oracle Corp."),
        Stock(symbol: "PYPL", name: "PayPal Holdings"),
        Stock(symbol: "ADBE", name: "Adobe Inc."),
        Stock(symbol: "QCOM", name: "Qualcomm Inc."),
        Stock(symbol: "UBER", name: "Uber Technologies"),
        Stock(symbol: "SNAP", name: "Snap Inc."),
        Stock(symbol: "SHOP", name: "Shopify Inc."),
        Stock(symbol: "SQ", name: "Block Inc."),
        Stock(symbol: "IBM", name: "IBM Corp."),
        Stock(symbol: "BABA", name: "Alibaba Group"),
        Stock(symbol: "JPM", name: "JPMorgan Chase"),
        Stock(symbol: "BAC", name: "Bank of America"),
        Stock(symbol: "DIS", name: "Walt Disney Co."),
        Stock(symbol: "SONY", name: "Sony Group Corp.")
    ]
}
