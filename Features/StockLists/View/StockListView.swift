//
//  StockListView.swift
//  MultiBankTask
//
//  Created by Alexey Bulatnikov on 3/1/26.
//

import SwiftUI

struct StockListView: View {
    @ObservedObject var viewModel: StockListViewModel
    @State private var navigationPath = NavigationPath()
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.sortedStocks) { stock in
                        StockRowView(stock: stock)
                            .padding(.horizontal, 16)
                            .onTapGesture {
                                navigationPath.append(stock)
                            }
                    }
                }
                .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Market Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                
                // Left: Connection Status
                ToolbarItem(placement: .navigationBarLeading) {
                    ConnectionStatusView(
                        status: viewModel.connectionStatus,
                        messagesSent: viewModel.messagesSent,
                        messagesReceived: viewModel.messagesReceived
                    )
                }
                
                // Center: Theme Changer
                ToolbarItem(placement: .principal) {
                    ThemeChangerView()
                }
                
                // Right: Start/Stop Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.toggleFeed()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.isFeedActive ? "stop.circle.fill" : "play.circle.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text(viewModel.isFeedActive ? "Stop" : "Start")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(viewModel.isFeedActive ?
                                      Color.red.opacity(0.15) :
                                      Color.green.opacity(0.15))
                        )
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                        .foregroundColor(viewModel.isFeedActive ? .red : .green)
                    }
                }
            }
            .navigationDestination(for: Stock.self) { stock in
                StockDetailView(symbol: stock.symbol)
            }
            .refreshable {
                if viewModel.isFeedActive {
                    viewModel.toggleFeed()
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    viewModel.toggleFeed()
                }
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    let webSocketService = WebSocketService()
    let stockService = StockService()
    let viewModel = StockListViewModel(
        webSocketService: webSocketService,
        stockService: stockService
    )
    
    return StockListView(viewModel: viewModel)
}
