//
//  StockDetailView.swift
//  MultiBankTask
//
//  Created by Alexey Bulatnikov on 3/1/26.
//

import SwiftUI

struct StockDetailView: View {
    let symbol: String
    @EnvironmentObject private var listViewModel: StockListViewModel
    @StateObject private var viewModel: StockDetailViewModel
    @State private var selectedSegment = 0
    
    init(symbol: String) {
        self.symbol = symbol
        _viewModel = StateObject(wrappedValue: StockDetailViewModel())
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let stock = viewModel.stock {
                    
                   
                    VStack(spacing: 16) {
                        Text(stock.symbol)
                            .font(.system(size: 44, weight: .bold))
                        
                        Text(stock.name)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        
                        
               
                        VStack(spacing: 8) {
                            
                           
                            Text("$\(PriceFormatter.plainPrice(stock.currentPrice))")
                                .font(.system(size: 56, weight: .bold))
                                .foregroundColor(.primary)
                            
                     
                            
                            HStack(spacing: 12) {
                                
                                
                                HStack(spacing: 4) {
                                    Image(systemName: stock.isPriceUp ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                        .font(.system(size: 16))
                                    
                                    Text(PriceFormatter.change(stock.priceChange))
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                
                          
                                Text("•")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                
                                
                                Text(PriceFormatter.percent(stock.priceChangePercentage))
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(stock.isPriceUp ? .green : .red)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                Capsule()
                                    .fill(stock.isPriceUp ?
                                          Color.green.opacity(0.15) :
                                          Color.red.opacity(0.15))
                            )
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(flashColor)
                        )
                        
                        Divider()
                        
                        // Stats
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Previous Close")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("$\(PriceFormatter.plainPrice(stock.previousPrice))")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Last Updated")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(stock.lastUpdated, style: .time)
                                    .font(.headline)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal)
                    
                    // Description Card
                    VStack(alignment: .leading, spacing: 12) {
                        Label("About \(stock.symbol)", systemImage: "info.circle")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text(viewModel.companyDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal)
                    
                } else {
                    ProgressView("Loading \(symbol)...")
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(symbol)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadStock()
        }
        .onReceive(listViewModel.$stocks) { stocks in
            if let updatedStock = stocks.first(where: { $0.symbol == symbol }) {
                viewModel.updateStock(updatedStock)
            }
        }
    }
    
    private var flashColor: Color {
        switch viewModel.priceFlashState {
        case .increase:
            return Color.green.opacity(0.2)
        case .decrease:
            return Color.red.opacity(0.2)
        case .none:
            return Color.clear
        }
    }
    
    private func loadStock() {
        if let stock = listViewModel.stock(for: symbol) {
            viewModel.updateStock(stock)
        }
    }
}


extension PriceFormatter {
    static func plainPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        
        return formatter.string(from: NSNumber(value: price)) ?? String(format: "%.2f", price)
    }
}

// MARK: - Preview
#Preview {
    // Creates mock services for preview
    let webSocketService = WebSocketService()
    let stockService = StockService()
    let viewModel = StockListViewModel(
        webSocketService: webSocketService,
        stockService: stockService
    )
    
    return NavigationStack {
        StockDetailView(symbol: "AAPL")
            .environmentObject(viewModel)
    }
}
