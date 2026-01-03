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
    @State private var showClaimSheet = false
    @State private var selectedService: Service?
    @State private var isLoadingDetails = false
    @State private var phoneNumber: String?
    @State private var website: String?
    @State private var openingHours: [String]?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header image (Async or Placeholder)
                    if let imageURL = business.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 250)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.1))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 250)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                            case .failure:
                                placeholderImage
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        placeholderImage
                    }
                    
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
                            // Address with Map Button
                            HStack {
                                HStack(spacing: 12) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.title3)
                                        .foregroundColor(.orange)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Adres")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(business.address)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                
                                Spacer()
                                
                                // Map Button
                                Button {
                                    let query = "\(business.name) \(business.address)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                    if let url = URL(string: "http://maps.apple.com/?q=\(query)") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Image(systemName: "map.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Circle().fill(Color.orange))
                                        .shadow(radius: 2)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            // Rating
                            if let rating = business.rating, let reviewCount = business.reviewCount {
                                BusinessInfoRow(icon: "star.fill", title: "Değerlendirme", value: "\(String(format: "%.1f", rating)) (\(reviewCount) yorum)")
                            }
                            
                            // Opening Hours
                            if let hours = openingHours, !hours.isEmpty {
                                DisclosureGroup {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(hours, id: \.self) { hour in
                                            Text(hour)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.top, 8)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "clock.fill")
                                            .font(.title3)
                                            .foregroundColor(.orange)
                                            .frame(width: 30)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Çalışma Saatleri")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text(business.isOpen == true ? "Şu an Açık" : "Şu an Kapalı")
                                                .font(.subheadline)
                                                .foregroundColor(business.isOpen == true ? .green : .red)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            } else if let isOpen = business.isOpen {
                                // Fallback simple status
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
                        
                        // Claim Business (Only for Google Listings)
                        if business.isGoogleListing {
                            Divider()
                            Button {
                                if authManager.isAuthenticated {
                                    showClaimSheet = true
                                } else {
                                    showLoginAlert = true
                                }
                            } label: {
                                Text("İşletme sahibi misiniz?")
                                    .font(.footnote)
                                    .foregroundColor(.primaryOrange)
                                    .padding(.vertical, 8)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Bottom padding
                        Color.clear.frame(height: 80)
                    }
                    .padding()
                }
            }
            .background(Color.bgPrimary)
            
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
        .navigationTitle(business.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Load extra details if this is a Google Listing
            if business.isGoogleListing, let placeId = business.googlePlaceId {
                loadGoogleDetails(placeId: placeId)
            }
        }
        .alert("Giriş Gerekli", isPresented: $showLoginAlert) {
            Button("Giriş Yap") { showLoginSheet = true }
            Button("Vazgeç", role: .cancel) { }
        } message: {
            Text("Randevu almak için giriş yapmanız gerekmektedir.")
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginScene()
        }
        .sheet(isPresented: $showClaimSheet) {
            ClaimBusinessSheet(business: business)
        }
        .sheet(isPresented: $showServiceSelection) {
            ServiceSelectionSheet(business: business) { service in
                showServiceSelection = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectedService = service
                }
            }
        }
        .sheet(item: $selectedService) { service in
            BookingScene(business: business, service: service)
        }
    }
    
    // Components
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(LinearGradient(colors: [.orange.opacity(0.3), .red.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(height: 250)
            .overlay(Image(systemName: "building.2.fill").font(.system(size: 80)).foregroundColor(.orange.opacity(0.5)))
    }
    
    private var hasContactInfo: Bool {
        return phoneNumber != nil || website != nil
    }
    
    // Logic
    private func loadGoogleDetails(placeId: String) {
        isLoadingDetails = true
        GooglePlacesManager.shared.getPlaceDetails(placeId: placeId) { result in
            DispatchQueue.main.async {
                isLoadingDetails = false
                switch result {
                case .success(let details):
                    self.phoneNumber = details.formatted_phone_number
                    self.website = details.website
                    self.openingHours = details.opening_hours?.weekday_text
                case .failure(let error):
                    print("❌ Failed to load details: \(error.localizedDescription)")
                }
            }
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
