//
//  CategoryChip.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 21.12.2025.
//

import SwiftUI

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                    AnyView(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)) :
                    AnyView(Color.white)
                )
                .cornerRadius(20)
                .shadow(color: isSelected ? .orange.opacity(0.3) : .black.opacity(0.05), radius: 4, y: 2)
        }
    }
}

#Preview {
    HStack {
        CategoryChip(title: "Tümü", isSelected: true, action: {})
        CategoryChip(title: "Restoran", isSelected: false, action: {})
        CategoryChip(title: "Kuaför", isSelected: false, action: {})
    }
    .padding()
}
