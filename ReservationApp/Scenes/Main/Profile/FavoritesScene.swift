//
//  FavoritesScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct FavoritesScene: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var favorites: [BusinessListing] = []
    @State private var isLoading = false
    private let favoritesManager = FavoritesManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                } else if favorites.isEmpty {
                    emptyView
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(favorites) { business in
                            FavoriteBusinessCard(business: business)
                        }
                    }
                    .padding(20)
                }
            }
            .background(Color.bgPrimary)
            .navigationTitle("Favoriler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Geri") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadFavorites()
            }
            .onReceive(NotificationCenter.default.publisher(for: FavoritesManager.favoritesDidChange)) { _ in
                print("📢 Favorites changed notification received, reloading...")
                loadFavorites()
            }
            .refreshable {
                loadFavorites()
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.textLight)
            
            Text("Henüz Favori Yok")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("Beğendiğiniz işletmeleri favorilere ekleyin")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    private func loadFavorites() {
        guard let userId = authManager.currentUser?.uid else {
            print("⚠️ FavoritesScene: No user logged in")
            favorites = []
            isLoading = false
            return
        }
        
        print("\n" + String(repeating: "🔄", count: 30))
        print("🔄 FavoritesScene: Loading favorites")
        print("   User ID: \(userId)")
        print("   Current favorites in AuthManager: \(authManager.currentUser?.favoriteBusinessIds?.count ?? 0)")
        print(String(repeating: "🔄", count: 30) + "\n")
        
        isLoading = true
        
        favoritesManager.getFavoriteBusinesses(userId: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let businesses):
                    print("\n" + String(repeating: "✅", count: 30))
                    print("✅ FavoritesScene: Loaded \(businesses.count) favorite businesses")
                    if !businesses.isEmpty {
                        print("   Businesses:")
                        businesses.forEach { business in
                            print("      - \(business.name) (ID: \(business.businessId))")
                        }
                    }
                    print(String(repeating: "✅", count: 30) + "\n")
                    favorites = businesses
                    
                case .failure(let error):
                    print("\n❌ FavoritesScene: Failed to load favorites: \(error)\n")
                    favorites = []
                }
            }
        }
    }
}

// MARK: - Favorite Business Card
struct FavoriteBusinessCard: View {
    let business: BusinessListing
    @State private var isFavorite = true
    @EnvironmentObject var authManager: AuthManager
    private let favoritesManager = FavoritesManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            // Business Image
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient.primaryGradient.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "building.2.fill")
                    .font(.title)
                    .foregroundColor(.primaryOrange)
            }
            
            // Business Info
            VStack(alignment: .leading, spacing: 6) {
                Text(business.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(business.category)
                    .font(.caption)
                    .foregroundColor(.primaryOrange)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                    Text(business.address)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundColor(.textSecondary)
                
                if let rating = business.rating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Favorite Button
            Button(action: {
                guard let userId = authManager.currentUser?.uid else { return }
                
                if isFavorite {
                    // Remove from favorites
                    favoritesManager.removeFromFavorites(userId: userId, businessId: business.businessId) { result in
                        DispatchQueue.main.async {
                            if case .success = result {
                                isFavorite = false
                                print("✅ Removed from favorites")
                            }
                        }
                    }
                } else {
                    // Add to favorites
                    favoritesManager.addToFavorites(userId: userId, businessId: business.businessId) { result in
                        DispatchQueue.main.async {
                            if case .success = result {
                                isFavorite = true
                                print("✅ Added to favorites")
                            }
                        }
                    }
                }
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundColor(isFavorite ? .red : .textLight)
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(16)
    }
}

#Preview {
    FavoritesScene()
}

