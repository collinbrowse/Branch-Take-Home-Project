//
//  ErrorView.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/18/25.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Spacer()
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 20))
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true) // Prevents text truncation
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemRed).opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
//        .transition(.move(edge: .top).combined(with: .opacity)) // Smooth entrance
    }
}
