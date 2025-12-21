//
//  LoginViewModel.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var loginSuccessId: UUID?
    @Published var needsPhoneVerification = false
    @Published var loggedInUser: User?
    
    private let authManager = AuthManager.shared
    
    func login() {
        print("🔵 Login button pressed")
        print("🔵 Email: \(email)")
        print("🔵 Password length: \(password.count)")
        
        guard validateInput() else {
            print("❌ Validation failed: \(errorMessage ?? "Unknown error")")
            return
        }
        
        print("✅ Validation passed, calling authManager.signIn...")
        isLoading = true
        errorMessage = nil
        
        authManager.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    print("✅ Login successful! User: \(user.name)")
                    print("✅ User ID: \(user.uid)")
                    print("✅ User type: \(user.userType)")
                    print("✅ Phone verified: \(user.phoneVerified)")
                    self?.loggedInUser = user
                    
                    // Check if phone is verified
                    if user.phoneVerified == true {
                        // Phone verified, navigate to home - use UUID to trigger navigation every time
                        print("✅ Phone verified, setting loginSuccessId")
                        self?.loginSuccessId = UUID()
                    } else {
                        // Phone not verified, navigate to verification
                        print("⚠️ Phone not verified, showing verification screen")
                        self?.needsPhoneVerification = true
                    }
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Login error: \(error.localizedDescription)")
                    print("❌ Full error: \(error)")
                }
            }
        }
    }
    
    private func validateInput() -> Bool {
        guard !email.isEmpty else {
            errorMessage = "Lütfen e-posta adresinizi girin"
            return false
        }
        
        guard Util.isValidEmail(email) else {
            errorMessage = "Geçerli bir e-posta adresi girin"
            return false
        }
        
        guard !password.isEmpty else {
            errorMessage = "Lütfen şifrenizi girin"
            return false
        }
        
        return true
    }
}
