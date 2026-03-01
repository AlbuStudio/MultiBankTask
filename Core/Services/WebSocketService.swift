//
//  WebSocketService.swift
//  MultiBankTask
//
//  Created by Alexey Bulatnikov on 3/1/26.
//

import Foundation
import Combine

// Represents the current WebSocket connection state

enum ConnectionStatus: String {
    case connected = "connected"
    case disconnected = "disconnected"
    case connecting = "connecting"
}

// WebSocket message structure for price updates.
struct PriceUpdateMessage: Codable {
    let symbol: String
    let price: Double
}

// Manages WebSocket connection and message streaming
final class WebSocketService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected
    @Published private(set) var messagesSent: Int = 0
    @Published private(set) var messagesReceived: Int = 0
    
    // MARK: - Public Publishers.
    let receivedMessagePublisher = PassthroughSubject<PriceUpdateMessage, Never>()
    let connectionStatusPublisher = PassthroughSubject<ConnectionStatus, Never>()
    
    // MARK: - Private Properties.
    private var webSocketTask: URLSessionWebSocketTask?
    private let url: URL
    private var pingTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 3
    private var isActive = false
    
    // MARK: - Initialization.
    init(url: URL = URL(string: "wss://ws.postman-echo.com/raw")!) {
        self.url = url
    }
    
    deinit {
        disconnect()
    }
    
    // MARK: Public Methods
    
    // Establishes WebSocket connection
    func connect() {
        guard connectionStatus != .connected else { return }
        
        connectionStatus = .connecting
        connectionStatusPublisher.send(.connecting)
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        startListening()
        startPingTimer()
        
        // Simulate connection establishment for demo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.handleConnectionEstablished()
        }
    }
    
    // Disconnects WebSocket
    func disconnect() {
        isActive = false
        stopPingTimer()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        DispatchQueue.main.async { [weak self] in
            self?.connectionStatus = .disconnected
            self?.connectionStatusPublisher.send(.disconnected)
            self?.reconnectAttempts = 0
        }
    }
    
    //Sends a price update message
    func sendPriceUpdate(symbol: String, price: Double) {
        let message = PriceUpdateMessage(symbol: symbol, price: price)
        
        guard let jsonData = try? JSONEncoder().encode(message),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
        
        webSocketTask?.send(wsMessage) { [weak self] error in
            if let error = error {
                print("Failed to send message: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.messagesSent += 1
            }
        }
    }
    
    // Starts generating random price updates
    func startPriceFeed(symbols: [String]) {
        isActive = true
        
        // Generate initial random prices
        symbols.forEach { symbol in
            let randomPrice = Double.random(in: 50...1000).rounded(to: 2)
            sendPriceUpdate(symbol: symbol, price: randomPrice)
        }
        
        // Schedule periodic updates
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard self?.isActive == true else {
                timer.invalidate()
                return
            }
            
            symbols.forEach { symbol in
                let randomPrice = Double.random(in: 50...1000).rounded(to: 2)
                self?.sendPriceUpdate(symbol: symbol, price: randomPrice)
            }
        }
    }
    
    // Stops the price feed
    func stopPriceFeed() {
        isActive = false
    }
    
    // MARK: - Private Methods
    
    private func handleConnectionEstablished() {
        connectionStatus = .connected
        connectionStatusPublisher.send(.connected)
        reconnectAttempts = 0
    }
    
    private func startListening() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleReceivedMessage(message)
                self?.startListening() // Continue listening
                
            case .failure(let error):
                print("WebSocket receive error: \(error.localizedDescription)")
                self?.handleDisconnection()
            }
        }
    }
    
    private func handleReceivedMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            processIncomingMessage(text)
        case .data(let data):
            if let text = String(data: data, encoding: .utf8) {
                processIncomingMessage(text)
            }
        @unknown default:
            break
        }
    }
    
    private func processIncomingMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let update = try? JSONDecoder().decode(PriceUpdateMessage.self, from: data) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.messagesReceived += 1
            self?.receivedMessagePublisher.send(update)
        }
    }
    
    private func handleDisconnection() {
        DispatchQueue.main.async { [weak self] in
            self?.connectionStatus = .disconnected
            self?.connectionStatusPublisher.send(.disconnected)
            
            // Attempt to reconnect if appropriate
            self?.attemptReconnection()
        }
    }
    
    private func attemptReconnection() {
        guard reconnectAttempts < maxReconnectAttempts else { return }
        
        reconnectAttempts += 1
        let delay = Double(reconnectAttempts) * 2.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.connect()
        }
    }
    
    private func startPingTimer() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    private func sendPing() {
        let pingMessage = URLSessionWebSocketTask.Message.string("ping")
        webSocketTask?.send(pingMessage) { _ in }
    }
}
