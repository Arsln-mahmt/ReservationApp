//
//  AdminDashboard.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 21.12.2025.
//

import SwiftUI
import FirebaseFirestore

struct AdminDashboard: View {
    @State private var requests: [ClaimRequest] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            List {
                if requests.isEmpty && !isLoading {
                    Text("Bekleyen talep yok.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(requests) { request in
                        ClaimRequestRow(request: request) {
                            approveRequest(request)
                        } rejectAction: {
                            rejectRequest(request)
                        }
                    }
                }
            }
            .navigationTitle("Yönetici Paneli")
            .task {
                loadRequests()
            }
            .refreshable {
                loadRequests()
            }
        }
    }
    
    private func loadRequests() {
        isLoading = true
        let db = Firestore.firestore()
        db.collection("claim_requests")
            .whereField("status", isEqualTo: ClaimStatus.pending.rawValue)
            .getDocuments { snapshot, error in
                isLoading = false
                if let snapshot = snapshot {
                    self.requests = snapshot.documents.compactMap { doc in
                        try? doc.data(as: ClaimRequest.self)
                    }
                }
            }
    }
    
    private func approveRequest(_ request: ClaimRequest) {
        let db = Firestore.firestore()
        
        // 1. Fetch Google Place Details
        GooglePlacesManager.shared.getPlaceDetails(placeId: request.googlePlaceId) { result in
            DispatchQueue.main.async {
                // Prepare business data with defaults
                var businessData: [String: Any] = [
                    "businessId": request.userId,
                    "name": request.businessName,
                    "address": request.businessAddress,
                    "city": "Mersin", // Can be parsed from address later
                    "category": "Genel", // Default
                    "rating": 0.0,
                    "reviewCount": 0,
                    "googlePlaceId": request.googlePlaceId,
                    "isGoogleListing": false,
                    "isClaimed": true,
                    "claimedBy": request.userId,
                    "createdAt": FieldValue.serverTimestamp(),
                    "hasActiveServices": false
                ]
                
                // If success, enrich data
                switch result {
                case .success(let details):
                    print("✅ Google Details fetched: \(details.name)")
                    
                    businessData["name"] = details.name
                    if let address = details.formatted_address {
                        businessData["address"] = address
                    }
                    businessData["rating"] = details.rating
                    businessData["reviewCount"] = details.user_ratings_total
                    businessData["phoneNumber"] = details.formatted_phone_number
                    businessData["website"] = details.website
                    businessData["openingHours"] = details.opening_hours?.weekday_text
                    businessData["isOpen"] = details.opening_hours?.open_now ?? true
                    
                    // Determine Category from Google Types
                    if let types = details.types {
                        if types.contains("beauty_salon") || types.contains("hair_care") || types.contains("spa") || types.contains("barber_shop") {
                            businessData["category"] = "Kuaför & Güzellik"
                        } else if types.contains("dentist") || types.contains("doctor") || types.contains("health") || types.contains("hospital") || types.contains("physiotherapist") {
                            businessData["category"] = "Klinik"
                        } else if types.contains("restaurant") || types.contains("cafe") || types.contains("bar") || types.contains("food") || types.contains("bakery") || types.contains("meal_takeaway") {
                            businessData["category"] = "Restoran"
                        } else if types.contains("gym") || types.contains("fitness_center") || types.contains("sports_complex") {
                            businessData["category"] = "Spor Salonu"
                        } else if types.contains("car_wash") || types.contains("car_repair") {
                            businessData["category"] = "Oto Yıkama & Servis"
                        } else {
                            businessData["category"] = "Diğer"
                        }
                    } else {
                        businessData["category"] = "Diğer"
                    }
                    
                    // Photos
                    if let photos = details.photos, !photos.isEmpty {
                        let photoURLs = photos.prefix(5).map { photo in
                            GooglePlacesManager.shared.getPhotoURL(photoReference: photo.photo_reference)
                        }
                        businessData["photos"] = photoURLs
                        // Use first photo as cover image if generated
                        businessData["imageURL"] = photoURLs.first
                    }
                    
                case .failure(let error):
                    print("⚠️ Failed to fetch details: \(error.localizedDescription). Creating basic listing.")
                }
                
                // 2. Save into Firestore 'businesses'
                db.collection("businesses").document(request.userId).setData(businessData) { error in
                    if let error = error {
                        print("❌ Error creating business: \(error.localizedDescription)")
                        return
                    }
                    
                    print("✅ Business created for user: \(request.userId)")
                    
                    // 2.1 Update User Profile to reflect business ownership
                    // This ensures AuthManager.currentUser has the correct business details
                    db.collection("users").document(request.userId).updateData([
                        "businessName": businessData["name"] as? String ?? "",
                        "businessCategory": businessData["category"] as? String ?? "",
                        "userType": "business"
                    ]) { _ in
                        print("✅ User profile updated to business type")
                    }
                    
                    // 3. Mark request as approved
                    if let id = request.id {
                        db.collection("claim_requests").document(id).updateData([
                            "status": ClaimStatus.approved.rawValue
                        ])
                        
                        // Remove from local list
                        if let index = requests.firstIndex(where: { $0.id == id }) {
                            requests.remove(at: index)
                        }
                    }
                }
            }
        }
    }
    
    private func rejectRequest(_ request: ClaimRequest) {
        let db = Firestore.firestore()
        if let id = request.id {
            db.collection("claim_requests").document(id).updateData([
                "status": ClaimStatus.rejected.rawValue
            ])
            
            if let index = requests.firstIndex(where: { $0.id == id }) {
                requests.remove(at: index)
            }
        }
    }
}

struct ClaimRequestRow: View {
    let request: ClaimRequest
    let approveAction: () -> Void
    let rejectAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(request.businessName)
                    .font(.headline)
                Spacer()
                Text(request.formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(request.businessAddress)
                .font(.caption)
                .foregroundColor(.gray)
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Talep Eden:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(request.requesterName)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Call Button
                if let url = URL(string: "tel://\(request.requesterPhone)"), UIApplication.shared.canOpenURL(url) {
                    Button {
                        UIApplication.shared.open(url)
                    } label: {
                        Image(systemName: "phone.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Text(request.requesterPhone)
                .font(.subheadline)
            
            HStack(spacing: 12) {
                Button(action: rejectAction) {
                    Text("Reddet")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
                
                Button(action: approveAction) {
                    Text("Onayla")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}
