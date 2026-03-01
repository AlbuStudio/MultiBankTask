//
//  ThemeChangerView.swift
//  MultiBankTask
//
//  Created by Alexey Bulatnikov on 3/1/26.
//

import SwiftUI

struct ThemeChangerView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isDarkMode.toggle()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isDarkMode ? .yellow : .orange)
                
                
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
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
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        ThemeChangerView()
    }
    .padding()
}
