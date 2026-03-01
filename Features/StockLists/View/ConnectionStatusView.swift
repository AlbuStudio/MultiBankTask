//
//  ConnectionStatusView.swift
//  MultiBankTask
//
//  Created by Alexey Bulatnikov on 3/1/26.
//

import SwiftUI

struct ConnectionStatusView: View {
    let status: ConnectionStatus
    let messagesSent: Int
    let messagesReceived: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                
                
                ZStack {
                    if status == .connected {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 10, height: 10)
                            .opacity(0.5)
                            .scaleEffect(1.5)
                            .animation(
                                Animation.easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true),
                                value: UUID()
                            )
                    }
                    
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                }
                
                Text(statusText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                if status == .connected {
                    HStack(spacing: 12) {
                        Label(
                            title: { Text("\(messagesSent)") },
                            icon: { Image(systemName: "arrow.up.circle.fill").foregroundColor(.green) }
                        )
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        
                        Label(
                            title: { Text("\(messagesReceived)") },
                            icon: { Image(systemName: "arrow.down.circle.fill").foregroundColor(.blue) }
                        )
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    }
                    .padding(.leading, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .overlay(
                Capsule()
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
        }
        .fixedSize(horizontal: true, vertical: false)
    }
    
    private var statusColor: Color {
        switch status {
        case .connected:
            return .green
        case .disconnected:
            return .red
        case .connecting:
            return .orange
        }
    }
    
    private var statusText: String {
        switch status {
        case .connected:
            return "Live"
        case .disconnected:
            return "Offline"
        case .connecting:
            return "Connecting"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ConnectionStatusView(status: .connected, messagesSent: 42, messagesReceived: 38)
        ConnectionStatusView(status: .connecting, messagesSent: 0, messagesReceived: 0)
        ConnectionStatusView(status: .disconnected, messagesSent: 0, messagesReceived: 0)
    }
    .padding()
}
