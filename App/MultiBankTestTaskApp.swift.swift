//
//  MultiBankTestTaskApp.swift
//  MultiBankTask
//
//  Created by Alexey Bulatnikov on 3/1/26.
//

import SwiftUI
import Combine

@main
struct MultiBankTestTaskApp: App {
    @StateObject private var appStore: AppStore
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    init() {
        
        // Dependency injection - create services first
        let webSocketService = WebSocketService()
        let stockService = StockService()
        
        // Create app store with injected dependencies
        _appStore = StateObject(wrappedValue: AppStore(
            webSocketService: webSocketService,
            stockService: stockService
        ))
        
        // Configure navigation bar appearance
        configureNavigationBar()
    }
    
    var body: some Scene {
        WindowGroup {
            StockListView(viewModel: appStore.stockListViewModel)
                .environmentObject(appStore)
                .preferredColorScheme(isDarkMode ? .dark : .light) // Worked
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "stocks",
              url.host == "symbol",
              let symbol = url.pathComponents.last else {
            return
        }
        
        
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenSymbol"),
            object: nil,
            userInfo: ["symbol": symbol]
        )
    }
}

// MARK: - App Store Shared State Container
final class AppStore: ObservableObject {
    let webSocketService: WebSocketService
    let stockService: StockService
    let stockListViewModel: StockListViewModel
    
    init(webSocketService: WebSocketService, stockService: StockService) {
        self.webSocketService = webSocketService
        self.stockService = stockService
        
        // Initialize view model with dependencies
        self.stockListViewModel = StockListViewModel(
            webSocketService: webSocketService,
            stockService: stockService
        )
        
        // Set up deep link handling
        setupDeepLinkHandling()
    }
    
    private func setupDeepLinkHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeepLinkNotification),
            name: NSNotification.Name("OpenSymbol"),
            object: nil
        )
    }
    
    @objc private func handleDeepLinkNotification(_ notification: Notification) {
        guard let symbol = notification.userInfo?["symbol"] as? String else { return }
        print("Deep link received for symbol: \(symbol)")
    
    }
}
