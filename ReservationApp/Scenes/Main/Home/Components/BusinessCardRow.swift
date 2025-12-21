//
//  BusinessCardRow.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 21.12.2025.
//

import SwiftUI

// MARK: - Business Card Row (for List)
struct BusinessCardRow: View {
    let business: BusinessListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [.orange.opacity(0.3), .red.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 140)
                .overlay(
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 8) {
                // Name
                Text(business.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Category
                HStack(spacing: 4) {
                    Image(systemName: "tag.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(business.category)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Rating
                if let rating = business.rating, let reviewCount = business.reviewCount {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("(\(reviewCount))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Address
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(business.address)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                // Status
                if let isOpen = business.isOpen {
                    Text(isOpen ? "Açık" : "Kapalı")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(isOpen ? .green : .red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background((isOpen ? Color.green : Color.red).opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

#Preview {
    BusinessCardRow(business: BusinessListing.sample)
        .padding()
}
