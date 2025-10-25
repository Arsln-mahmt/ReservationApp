//
//  RegisterViewModel.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

class RegisterViewModel: ObservableObject {
    @Published var registrationSuccess = false
    @Published var registeredUserId: String?
    // User info
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var userType: UserType = .customer
    
    // Business info (only if userType = business)
    @Published var businessName = ""
    @Published var businessAddress = ""
    @Published var businessCategory = ""
    
    // State
    @Published var isLoading = false
    @Published var isLoadingLocation = false
    @Published var errorMessage: String?
    @Published var showUserTypeSelection = true
    
    private let authManager = AuthManager.shared
    
    // MARK: - Register with Email/Password
    func register() {
        guard validateInput() else { return }
        
        isLoading = true
        errorMessage = nil
        
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        
        let businessNameValue = userType == .business ? businessName : nil
        let businessAddressValue = userType == .business ? businessAddress : nil
        let businessCategoryValue = userType == .business ? businessCategory : nil
        
        authManager.signUp(
            email: email,
            password: password,
            name: fullName,
            phoneNumber: phoneNumber,
            userType: userType,
            businessName: businessNameValue,
            businessAddress: businessAddressValue,
            businessCategory: businessCategoryValue
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    // Registration successful, navigate to phone verification
                    print("✅ Registration successful!")
                    self?.registeredUserId = user.uid
                    self?.registrationSuccess = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Registration error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Sign In with Apple
    func signInWithApple() {
        // TODO: Implement Apple Sign In
        errorMessage = "Apple Sign In yakında eklenecek"
    }
    
    // MARK: - Sign In with Google
    func signInWithGoogle() {
        // TODO: Implement Google Sign In
        errorMessage = "Google Sign In yakında eklenecek"
    }
    
    // MARK: - Get Current Location
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
    
    // MARK: - Validation
    private func validateInput() -> Bool {
        guard !firstName.isEmpty else {
            errorMessage = "Lütfen adınızı girin"
            return false
        }
        
        guard !lastName.isEmpty else {
            errorMessage = "Lütfen soyadınızı girin"
            return false
        }
        
        guard !email.isEmpty else {
            errorMessage = "Lütfen e-posta adresinizi girin"
            return false
        }
        
        guard Util.isValidEmail(email) else {
            errorMessage = "Geçerli bir e-posta adresi girin"
            return false
        }
        
        guard !phoneNumber.isEmpty else {
            errorMessage = "Lütfen telefon numaranızı girin"
            return false
        }
        
        guard !password.isEmpty else {
            errorMessage = "Lütfen şifre girin"
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "Şifre en az 6 karakter olmalı"
            return false
        }
        
        guard password == confirmPassword else {
            errorMessage = "Şifreler eşleşmiyor"
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
    
    // MARK: - User Type Selection
    func selectUserType(_ type: UserType) {
        userType = type
        withAnimation {
            showUserTypeSelection = false
        }
    }
}
