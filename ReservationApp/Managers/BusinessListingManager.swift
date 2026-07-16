//
//  BusinessListingManager.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import FirebaseFirestore
import Combine

class BusinessListingManager: ObservableObject {
    private lazy var db = Firestore.firestore()
    
    static let shared = BusinessListingManager()
    
    private init() {}
    
    // MARK: - Get All Business Listings
    func getAllBusinessListings(completion: @escaping (Result<[BusinessListing], Error>) -> Void) {
        db.collection(Constant.businessesCollection)
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
                    let listings = documents.compactMap { doc -> BusinessListing? in
                        do {
                            return try doc.data(as: BusinessListing.self)
                        } catch {
                            print("⚠️ Failed to decode listing \(doc.documentID): \(error)")
                            return nil
                        }
                    }
                    print("✅ Fetched \(listings.count) business listings")
                    completion(.success(listings))
                }
            }
    }
    
    // MARK: - Create or Update Business Listing
    func createOrUpdateBusinessListing(
        businessId: String,
        name: String,
        category: String,
        city: String,
        address: String,
        description: String?,
        phoneNumber: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Check if listing already exists
        db.collection(Constant.businessesCollection)
            .whereField("businessId", isEqualTo: businessId)
            .getDocuments { [weak self] snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let listing = BusinessListing(
                    id: nil,
                    businessId: businessId,
                    name: name,
                    category: category,
                    city: city,
                    address: address,
                    rating: nil,
                    reviewCount: 0,
                    imageURL: nil,
                    description: description,
                    priceRange: "$$",
                    isOpen: true,
                    distance: nil
                )
                
                if let existingDoc = snapshot?.documents.first {
                    // Update existing
                    self?.updateListing(documentId: existingDoc.documentID, listing: listing, completion: completion)
                } else {
                    // Create new
                    self?.createListing(listing: listing, completion: completion)
                }
            }
    }
    
    private func createListing(listing: BusinessListing, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection(Constant.businessesCollection)
                .addDocument(from: listing) { error in
                    if let error = error {
                        print("❌ Failed to create business listing: \(error)")
                        completion(.failure(error))
                    } else {
                        print("✅ Business listing created successfully")
                        completion(.success(()))
                    }
                }
        } catch {
            print("❌ Failed to encode business listing: \(error)")
            completion(.failure(error))
        }
    }
    
    private func updateListing(documentId: String, listing: BusinessListing, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection(Constant.businessesCollection)
                .document(documentId)
                .setData(from: listing, merge: true) { error in
                    if let error = error {
                        print("❌ Failed to update business listing: \(error)")
                        completion(.failure(error))
                    } else {
                        print("✅ Business listing updated successfully")
                        completion(.success(()))
                    }
                }
        } catch {
            print("❌ Failed to encode business listing: \(error)")
            completion(.failure(error))
        }
    }
    
    // MARK: - Get Business Listing by ID
    func getBusinessListing(businessId: String, completion: @escaping (Result<BusinessListing?, Error>) -> Void) {
        db.collection(Constant.businessesCollection)
            .whereField("businessId", isEqualTo: businessId)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Failed to fetch business listing: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    DispatchQueue.main.async {
                        completion(.success(nil))
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    do {
                        let listing = try document.data(as: BusinessListing.self)
                        print("✅ Fetched business listing: \(listing.name)")
                        completion(.success(listing))
                    } catch {
                        print("❌ Failed to decode business listing: \(error)")
                        completion(.failure(error))
                    }
                }
            }
    }
}

