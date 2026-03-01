//
//  StockListViewModel.swift
//  MultiBankTask
//
//  Created by Alexey Bulatnikov on 3/1/26.
//

import Foundation
import Combine


final class StockListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var stocks: [Stock] = []
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected
    @Published private(set) var isFeedActive: Bool = false
    @Published private(set) var messagesSent: Int = 0
    @Published private(set) var messagesReceived: Int = 0
    
    // MARK: - Computed Properties
    var sortedStocks: [Stock] {
        stocks.sorted { $0.currentPrice > $1.currentPrice }
    }
    
    // MARK: - Private Properties
    private let webSocketService: WebSocketService
    private let stockService: StockService
    private var cancellables = Set<AnyCancellable>()
    private var feedTimer: Timer?
    
    // MARK: - Initialization
    init(webSocketService: WebSocketService, stockService: StockService) {
        self.webSocketService = webSocketService
        self.stockService = stockService
        
        setupBindings()
        loadStocks()
    }
    
    deinit {
        feedTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    /// Swich the price feed on-off
    func toggleFeed() {
        if isFeedActive {
            stopFeed()
        } else {
            startFeed()
        }
    }
    
    // Returns a stock for a given symbol
    func stock(for symbol: String) -> Stock? {
        stockService.stock(for: symbol)
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        
        webSocketService.$connectionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.connectionStatus = status
            }
            .store(in: &cancellables)
        
        
        webSocketService.receivedMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                self?.handlePriceUpdate(update)
            }
            .store(in: &cancellables)
        
       
        webSocketService.$messagesSent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.messagesSent = count
            }
            .store(in: &cancellables)
        
        webSocketService.$messagesReceived
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.messagesReceived = count
            }
            .store(in: &cancellables)
        
        
        stockService.$stocks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedStocks in
                self?.stocks = updatedStocks
            }
            .store(in: &cancellables)
    }
    
    private func loadStocks() {
        stocks = stockService.stocks
    }
    
    private func handlePriceUpdate(_ update: PriceUpdateMessage) {
        stockService.updateStockPrice(symbol: update.symbol, newPrice: update.price)
    }
    
    private func startFeed() {
        webSocketService.connect()
        
        // Wait for connection then start price feed
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            let symbols = self.stocks.map { $0.symbol }
            self.webSocketService.startPriceFeed(symbols: symbols)
            self.isFeedActive = true
        }
    }
    
    private func stopFeed() {
        webSocketService.stopPriceFeed()
        webSocketService.disconnect()
        isFeedActive = false
    }
}
