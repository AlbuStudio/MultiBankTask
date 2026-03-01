//
//  StockDetailViewModel.swift
//  MultiBankTask
//
//  Created by Alexey Bulatnikov on 3/1/26.
//

import Foundation
import Combine


final class StockDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var stock: Stock?
    @Published private(set) var priceFlashState: PriceFlashState = .none
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var flashWorkItem: DispatchWorkItem?
    
    // MARK: - Types
    enum PriceFlashState {
        case none
        case increase
        case decrease
    }
    
    // MARK: - Initialization
    init(stock: Stock? = nil) {
        self.stock = stock
    }
    
    deinit {
        flashWorkItem?.cancel()
    }
    
    // MARK: - Public Methods
    
    
    func updateStock(_ newStock: Stock) {
        let priceChanged = stock?.currentPrice != newStock.currentPrice
        let isIncrease = newStock.currentPrice > (stock?.currentPrice ?? 0)
        
        stock = newStock
        
        if priceChanged {
            triggerFlash(isIncrease: isIncrease)
        }
    }
    
    // Returns a company description
    var companyDescription: String {
        guard let symbol = stock?.symbol else {
            return "Select a stock to view details"
        }
        
        switch symbol {
        case "AAPL":
            return "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide."
        case "GOOG", "GOOGL":
            return "Alphabet Inc. provides various products and platforms including Google Search, Google Maps, YouTube, Android, and more."
        case "TSLA":
            return "Tesla, Inc. designs, develops, manufactures, and sells electric vehicles and energy generation and storage systems."
        case "AMZN":
            return "Amazon.com, Inc. engages in the retail sale of consumer products and subscriptions through online and physical stores."
        case "MSFT":
            return "Microsoft Corporation develops, licenses, and supports software, services, devices, and solutions worldwide."
        case "NVDA":
            return "NVIDIA Corporation provides graphics, compute and networking solutions for gaming, professional visualization, and automotive markets."
        default:
            return "\(symbol) is a publicly traded company. Current price reflects real-time market activity."
        }
    }
    
    // MARK: - Private Methods
    
    private func triggerFlash(isIncrease: Bool) {
        flashWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.priceFlashState = .none
        }
        
        flashWorkItem = workItem
        
        DispatchQueue.main.async {
            self.priceFlashState = isIncrease ? .increase : .decrease
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
        }
    }
}
