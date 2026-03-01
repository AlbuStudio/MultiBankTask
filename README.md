README for MultiBankTask App

What is this?

This is my stock tracking app I built for a coding challenge. It shows real-time stock prices using WebSockets. The app connects to an echo server and simulates price updates every 2 seconds for 25 different stocks. I tried to make it look decent with some glass morphism effects and added a dark and light mode toggle because I hate apps that blind you at night.

Features
    •    Live stock prices - Updates every 2 seconds (simulated prices).
    •    25 stocks - AAPL, GOOG, TSLA, AMZN, MSFT, NVDA and others.
    •    Sort by price - highest priced stocks show up first.
    •    Price changes - green arrow up if price increased, red down if decreased.
    •    Price flash - background flashes green and red for a second when price changes.
    •    Dark and light mode - toggle in the top center.
    •    Connection status - shows if WebSocket is live with message counters.
    •    Detail view - Tap any stock to see more info and company description.

Tech Stuff

Built with SwiftUI (all UI), Combine (for the WebSocket streams), MVVM architecture (keeps things organized), WebSocket (wss://ws.postman-echo.com/raw). The app has 2 screens (feed list and detail view), NavigationStack for navigation, shared WebSocket service (no duplicate connections), dependency injection (passing stuff where its needed).

Project Structure

I tried to keep things organized:

    •    App - MultiBankTestTaskApp.swift
    •    Models - Stock.swift
    •    Services - WebSocketService.swift, StockService.swift
    •    ViewModels - StockListViewModel.swift, StockDetailViewModel.swift
    •    Views - StockListView.swift, StockRowView.swift, StockDetailView.swift, ThemeChangerView.swift, Components - ConnectionStatusView.swift
    •    Utilities - PriceFormatter.swift, DoubleExtensions.swift

How to Run

    1    Clone the repo
    2    Open MultiBankTask.xcodeproj in Xcode 26
    3    Build and run on a simulator or real device
    4    Click "Start" to begin the price feed
    5    Tap any stock to see details
    6    Select dark or light mode from the top center

Known Issues

    •    The WebSocket is just an echo server so prices are random (NOT A REAL MARKET DATA)
    •    Sometimes connection takes a second to establish
  

What I'd Add If I Had More Time

    •    Real API integration (Alpha Vantage or something)
    •    Charts in the detail view
    •    Search/filter stocks
    •    Portfolio tracking
   
