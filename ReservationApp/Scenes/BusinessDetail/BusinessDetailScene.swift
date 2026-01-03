//
//  BusinessDetailScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 15.12.2025.
//

import SwiftUI

/// Detailed view for a selected business listing (Simplified - No Network Calls)
struct BusinessDetailScene: View {
    let business: BusinessListing
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image (AsyncImage or Placeholder)
                if let imageURL = business.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 200)
                                .background(Color.gray.opacity(0.1))
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 300)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(LinearGradient.primaryGradient.opacity(0.3))
                                .frame(maxWidth: .infinity, minHeight: 200)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // Placeholder image
                    Rectangle()
                        .fill(LinearGradient.primaryGradient.opacity(0.3))
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .overlay(
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.primaryOrange.opacity(0.5))
                        )
                }
                
                // Basic Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(business.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text(business.category)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.textSecondary)
                        Text(business.address)
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                    
                    if let distance = business.distance {
                        Text(String(format: "%.1f km uzaklıkta", distance))
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    if let rating = business.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
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
                
                // Description
                if let description = business.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.textPrimary)
                }
                
                // Price Range
                if let price = business.priceRange {
                    Text("Fiyat aralığı: \(price)")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding()
        }
        .navigationTitle(business.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
struct BusinessDetailScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BusinessDetailScene(business: BusinessListing.sample)
        }
    }
}
