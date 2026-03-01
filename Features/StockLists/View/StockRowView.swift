//
//  StockRowView.swift
//  MultiBankTask
//
//  Created by Alexey Bulatnikov on 3/1/26.
//

import SwiftUI

struct StockRowView: View {
    let stock: Stock
    @State private var priceBackgroundColor: Color = .clear
    @State private var isAnimating = false
    @State private var arrowOffset: CGFloat = 0
    @State private var arrowOpacity: Double = 0.7
    
    var body: some View {
        HStack(spacing: 8) {
            
            // Symbol and name - fixed width to prevent compression
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(stock.name)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: 100, alignment: .leading)
            }
            .frame(width: 100, alignment: .leading)
            
            Spacer(minLength: 4)
            
            // Price and change - fixed layout to prevent overflow
            VStack(alignment: .trailing, spacing: 4) {
                Text(PriceFormatter.price(stock.currentPrice))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                HStack(spacing: 6) {
                    
                    // Price change indicator with arrow
                    HStack(spacing: 2) {
                        Image(systemName: stock.isPriceUp ? "arrow.up" : "arrow.down")
                            .font(.system(size: 9, weight: .bold))
                        
                        Text(PriceFormatter.shortChange(stock.priceChange))
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(stock.isPriceUp ? .green : .red)
                    
                    // Percentage change
                    Text(PriceFormatter.shortPercent(stock.priceChangePercentage))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(stock.isPriceUp ? .green : .red)
                }
            }
            .frame(maxWidth: 130, alignment: .trailing)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(priceBackgroundColor)
            )
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            
            // Animated navigation arrow - white background
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.blue)
                .padding(8)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                )
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .offset(x: arrowOffset)
                .opacity(arrowOpacity)
                .onAppear {
                    startArrowAnimation()
                }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onChange(of: stock.currentPrice) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                priceBackgroundColor = newValue > oldValue ?
                    Color.green.opacity(0.3) : Color.red.opacity(0.3)
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    priceBackgroundColor = .clear
                    isAnimating = false
                }
            }
        }
    }
    
    private func startArrowAnimation() {
        arrowOffset = 0
        arrowOpacity = 0.7
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(
                Animation.easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
            ) {
                arrowOffset = 5
                arrowOpacity = 1.0
            }
        }
    }
}

#Preview {
    let mockStock = Stock(
        symbol: "AAPL",
        name: "Apple Inc.",
        currentPrice: 875.50,
        previousPrice: 862.30
    )
    
    return ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()
        
        VStack(spacing: 12) {
            StockRowView(stock: mockStock)
            StockRowView(stock: mockStock)
            StockRowView(stock: mockStock)
        }
        .padding()
    }
}
