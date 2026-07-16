//
//  FavoritesManager.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 16.11.2025.
//

import Foundation
import FirebaseFirestore

class FavoritesManager {
    static let shared = FavoritesManager()
    private lazy var db = Firestore.firestore()
    
    // Notification name for favorite changes
    static let favoritesDidChange = Notification.Name("FavoritesDidChange")
    
    private init() {}
    
    // MARK: - Add to Favorites
    func addToFavorites(userId: String, businessId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("💝 Adding business \(businessId) to favorites for user \(userId)")
        
        // 1. Update local state immediately
        if var currentUser = AuthManager.shared.currentUser {
            if currentUser.favoriteBusinessIds == nil {
                currentUser.favoriteBusinessIds = []
            }
            if !currentUser.favoriteBusinessIds!.contains(businessId) {
                currentUser.favoriteBusinessIds!.append(businessId)
                AuthManager.shared.updateCurrentUser(currentUser)
                print("✅ Updated local favorites immediately")
                
                // Notify all screens
                NotificationCenter.default.post(name: FavoritesManager.favoritesDidChange, object: nil)
            }
        }
        
        // 2. Update Firebase
        db.collection(Constant.usersCollection)
            .document(userId)
            .updateData([
                "favoriteBusinessIds": FieldValue.arrayUnion([businessId])
            ]) { error in
                if let error = error {
                    print("❌ Failed to add favorite: \(error)")
                    // Rollback local change on error
                    if var currentUser = AuthManager.shared.currentUser {
                        currentUser.favoriteBusinessIds?.removeAll { $0 == businessId }
                        AuthManager.shared.updateCurrentUser(currentUser)
                    }
                    completion(.failure(error))
                } else {
                    print("✅ Added to favorites in Firebase successfully")
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Remove from Favorites
    func removeFromFavorites(userId: String, businessId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("💔 Removing business \(businessId) from favorites for user \(userId)")
        
        // 1. Update local state immediately
        var removedBusinessId: String?
        if var currentUser = AuthManager.shared.currentUser {
            if let index = currentUser.favoriteBusinessIds?.firstIndex(of: businessId) {
                removedBusinessId = businessId
                currentUser.favoriteBusinessIds?.remove(at: index)
                AuthManager.shared.updateCurrentUser(currentUser)
                print("✅ Updated local favorites immediately")
                
                // Notify all screens
                NotificationCenter.default.post(name: FavoritesManager.favoritesDidChange, object: nil)
            }
        }
        
        // 2. Update Firebase
        db.collection(Constant.usersCollection)
            .document(userId)
            .updateData([
                "favoriteBusinessIds": FieldValue.arrayRemove([businessId])
            ]) { error in
                if let error = error {
                    print("❌ Failed to remove favorite: \(error)")
                    // Rollback local change on error
                    if var currentUser = AuthManager.shared.currentUser, let businessId = removedBusinessId {
                        if currentUser.favoriteBusinessIds == nil {
                            currentUser.favoriteBusinessIds = []
                        }
                        currentUser.favoriteBusinessIds!.append(businessId)
                        AuthManager.shared.updateCurrentUser(currentUser)
                    }
                    completion(.failure(error))
                } else {
                    print("✅ Removed from favorites in Firebase successfully")
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Check if Business is Favorite
    func isFavorite(userId: String, businessId: String) -> Bool {
        guard let user = AuthManager.shared.currentUser else { return false }
        return user.favoriteBusinessIds?.contains(businessId) ?? false
    }
    
    // MARK: - Get Favorite Businesses
    func getFavoriteBusinesses(userId: String, completion: @escaping (Result<[BusinessListing], Error>) -> Void) {
        print("\n📖 Loading favorite businesses for user: \(userId)")
        
        // First try to get from local state (AuthManager)
        if let favoriteIds = AuthManager.shared.currentUser?.favoriteBusinessIds, !favoriteIds.isEmpty {
            print("📋 Using local state: \(favoriteIds.count) favorite IDs")
            fetchBusinessListings(for: favoriteIds, completion: completion)
            return
        }
        
        // If not in local state, fetch from Firebase
        print("🔄 Fetching from Firebase...")
        db.collection(Constant.usersCollection)
            .document(userId)
            .getDocument { [weak self] snapshot, error in
                
                if let error = error {
                    print("❌ Failed to fetch user: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = snapshot?.data(),
                      let favoriteIds = data["favoriteBusinessIds"] as? [String],
                      !favoriteIds.isEmpty else {
                    print("⚠️ No favorite businesses in Firebase")
                    completion(.success([]))
                    return
                }
                
                print("📋 Found \(favoriteIds.count) favorite IDs in Firebase: \(favoriteIds)")
                
                // Fetch business listings for these IDs
                self?.fetchBusinessListings(for: favoriteIds, completion: completion)
            }
    }
    
    // MARK: - Fetch Business Listings
    private func fetchBusinessListings(for businessIds: [String], completion: @escaping (Result<[BusinessListing], Error>) -> Void) {
        db.collection(Constant.businessesCollection)
            .whereField("businessId", in: businessIds)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Failed to fetch business listings: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    do {
                        let businesses = try documents.map { doc in
                            try doc.data(as: BusinessListing.self)
                        }
                        print("✅ Fetched \(businesses.count) favorite businesses")
                        completion(.success(businesses))
                    } catch {
                        print("❌ Failed to decode business listings: \(error)")
                        completion(.failure(error))
                    }
                }
            }
    }
    
    // MARK: - Refresh User Favorites in AuthManager
    private func refreshUserFavorites(userId: String) {
        db.collection(Constant.usersCollection)
            .document(userId)
            .getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    DispatchQueue.main.async {
                        if let user = try? Firestore.Decoder().decode(User.self, from: data) {
                            AuthManager.shared.updateCurrentUser(user)
                        }
                    }
                }
            }
    }
}

