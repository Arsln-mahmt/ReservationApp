//
//  SimpleBusinessDetail.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 21.12.2025.
//

import SwiftUI

// MARK: - Simple Business Detail
struct SimpleBusinessDetail: View {
    let business: BusinessListing
    @EnvironmentObject var authManager: AuthManager
    @State private var showServiceSelection = false
    @State private var showLoginAlert = false
    @State private var showLoginSheet = false
    @State private var selectedService: Service?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header image
                    RoundedRectangle(cornerRadius: 0)
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .red.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.orange.opacity(0.5))
                        )
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Name and Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text(business.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(business.category)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Divider()
                        
                        // Info cards
                        VStack(spacing: 12) {
                            // Address
                            BusinessInfoRow(icon: "mappin.and.ellipse", title: "Adres", value: business.address)
                            
                            // Rating
                            if let rating = business.rating, let reviewCount = business.reviewCount {
                                BusinessInfoRow(icon: "star.fill", title: "Değerlendirme", value: "\(String(format: "%.1f", rating)) (\(reviewCount) yorum)")
                            }
                            
                            // Status
                            if let isOpen = business.isOpen {
                                HStack(spacing: 12) {
                                    Image(systemName: isOpen ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(isOpen ? .green : .red)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Durum")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(isOpen ? "Şu an açık" : "Şu an kapalı")
                                            .font(.subheadline)
                                            .foregroundColor(isOpen ? .green : .red)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            // Price
                            if let priceRange = business.priceRange {
                                BusinessInfoRow(icon: "creditcard", title: "Fiyat Aralığı", value: priceRange)
                            }
                        }
                        
                        // Description
                        if let description = business.description {
                            Divider()
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Hakkında")
                                    .font(.headline)
                                Text(description)
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Bottom padding for button
                        Color.clear.frame(height: 80)
                    }
                    .padding()
                }
            }
            
            // Fixed bottom button
            VStack(spacing: 0) {
                Divider()
                
                Button {
                    if authManager.isAuthenticated {
                        showServiceSelection = true
                    } else {
                        showLoginAlert = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                            .font(.title3)
                        Text("Randevu Al")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.primaryOrange, Color.primaryOrangeDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.bgPrimary)
            }
        }
        .background(Color.bgPrimary)
        .navigationTitle(business.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Giriş Gerekli", isPresented: $showLoginAlert) {
            Button("Giriş Yap") {
                showLoginSheet = true
            }
            Button("Vazgeç", role: .cancel) { }
        } message: {
            Text("Randevu almak için giriş yapmanız gerekmektedir.")
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginScene()
        }
        .sheet(isPresented: $showServiceSelection) {
            ServiceSelectionSheet(business: business) { service in
                showServiceSelection = false
                // Small delay to ensure sheet is closed before opening new one
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectedService = service
                }
            }
        }
        .sheet(item: $selectedService) { service in
            BookingScene(business: business, service: service)
        }
    }
}

// MARK: - Business Info Row
struct BusinessInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        SimpleBusinessDetail(business: BusinessListing.sample)
    }
}
