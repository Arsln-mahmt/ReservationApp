//
//  CompleteProfileViewModel.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

class CompleteProfileViewModel: ObservableObject {
    let userType: UserType
    let userId: String
    let email: String
    let name: String
    
    @Published var phoneNumber = ""
    @Published var businessName = ""
    @Published var businessAddress = ""
    @Published var businessCategory = ""
    
    @Published var isLoading = false
    @Published var isLoadingLocation = false
    @Published var errorMessage: String?
    
    init(userType: UserType, userId: String, email: String, name: String) {
        self.userType = userType
        self.userId = userId
        self.email = email
        self.name = name
    }
    
    func completeProfile(completion: @escaping (Bool) -> Void) {
        guard validateInput() else {
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Create User object
        let user = User(
            id: nil,
            uid: userId,
            email: email,
            name: name,
            phoneNumber: phoneNumber,
            phoneVerified: false,
            userType: userType,
            profileImageURL: nil,
            createdAt: Timestamp(),
            updatedAt: nil,
            businessName: userType == .business ? businessName : nil,
            businessAddress: userType == .business ? businessAddress : nil,
            businessCategory: userType == .business ? businessCategory : nil,
            businessDescription: nil,
            workingHours: nil
        )
        
        let db = Firestore.firestore()
        do {
            try db.collection(Constant.usersCollection)
                .document(userId)
                .setData(from: user) { [weak self] error in
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            completion(false)
        }
    }
    
    func getCurrentLocation() {
        isLoadingLocation = true
        errorMessage = nil
        
        LocationManager.shared.getCurrentLocation { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingLocation = false
                
                switch result {
                case .success(let address):
                    self?.businessAddress = address
                    print("✅ Location fetched: \(address)")
                    
                case .failure(let error):
                    if let locationError = error as? LocationError {
                        self?.errorMessage = locationError.localizedDescription
                        
                        // If permission not determined, show alert
                        if case .permissionNotDetermined = locationError {
                            // User needs to grant permission first
                            LocationManager.shared.requestPermission()
                        }
                    } else {
                        self?.errorMessage = "Konum alınamadı: \(error.localizedDescription)"
                    }
                    print("❌ Location error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func validateInput() -> Bool {
        guard !phoneNumber.isEmpty else {
            errorMessage = "Lütfen telefon numaranızı girin"
            return false
        }
        
        if userType == .business {
            guard !businessName.isEmpty else {
                errorMessage = "Lütfen işletme adını girin"
                return false
            }
            
            guard !businessAddress.isEmpty else {
                errorMessage = "Lütfen işletme adresini girin"
                return false
            }
        }
        
        return true
    }
}

