//
//  StockService.swift
//  MultiBankTask
//
//  Created by Alexey Bulatnikov on 3/1/26.
//

import Foundation
import Combine

// Manages stock data and updates.

final class StockService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var stocks: [Stock] = []
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let updateQueue = DispatchQueue(label: "com.multibanktask.stockservice", qos: .userInitiated)
    
    // MARK: - Initialization
    init() {
        loadInitialStocks()
    }
    
    // MARK: - Public Methods
    
    // Updates a stock's price
    func updateStockPrice(symbol: String, newPrice: Double) {
        updateQueue.async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                guard let index = self.stocks.firstIndex(where: { $0.symbol == symbol }) else { return }
                
                var updatedStock = self.stocks[index]
                updatedStock.previousPrice = updatedStock.currentPrice
                updatedStock.currentPrice = newPrice
                updatedStock.lastUpdated = Date()
                
                self.stocks[index] = updatedStock
            }
        }
    }
    
    //Updates multiple stock prices
    func updateStockPrices(_ updates: [(symbol: String, price: Double)]) {
        updateQueue.async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                for update in updates {
                    guard let index = self.stocks.firstIndex(where: { $0.symbol == update.symbol }) else { continue }
                    
                    var updatedStock = self.stocks[index]
                    updatedStock.previousPrice = updatedStock.currentPrice
                    updatedStock.currentPrice = update.price
                    updatedStock.lastUpdated = Date()
                    
                    self.stocks[index] = updatedStock
                }
            }
        }
    }
    
    // Returns a stock for a given symbol
    func stock(for symbol: String) -> Stock? {
        stocks.first { $0.symbol == symbol }
    }
    
    // MARK: - Private Methods
    
    private func loadInitialStocks() {
        stocks = Stock.mockStocks.map { stock in
            var mutableStock = stock
            // Initialize with realistic prices up to 999
            let randomPrice: Double
            switch stock.symbol {
            case "NVDA", "AVGO", "META":
                randomPrice = Double.random(in: 800...999)
            case "MSFT", "AAPL", "GOOG":
                randomPrice = Double.random(in: 150...500)
            case "TSLA", "AMD":
                randomPrice = Double.random(in: 150...300)
            case "JPM", "BAC", "V", "MA":
                randomPrice = Double.random(in: 50...200)
            default:
                randomPrice = Double.random(in: 50...400)
            }
            
            mutableStock.currentPrice = (randomPrice * 100).rounded() / 100
            mutableStock.previousPrice = mutableStock.currentPrice
            return mutableStock
        }
    }
}
