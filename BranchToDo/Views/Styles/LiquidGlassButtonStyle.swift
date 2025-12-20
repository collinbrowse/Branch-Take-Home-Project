//
//  LiquidGlassButtonStyle.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/18/25.
//

import SwiftUI

struct LiquidGlassButtonStyle: ButtonStyle {
    var isLoading: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundColor(.black)
            .opacity(isLoading ? 0 : 1) // Hide text when loading
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    // 1. The Glass Base
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color.white.opacity(0.15))
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.1))
                                .blur(radius: 4)
                        )
                    
                    // 2. The Liquid Border (Inner Glow)
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(LinearGradient(
                            colors: [.white.opacity(0.6), .clear, .white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 0.5)
                    
                    // 3. The Loading Indicator
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            .transition(.opacity)
                    }
                }
            )
            // Subtle "squish" effect when pressed
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.green
        Button {
            
        } label: {
            Text("Load Todos")
                .font(.headline)
        }
        .buttonStyle(LiquidGlassButtonStyle(isLoading: true))
    }
}
