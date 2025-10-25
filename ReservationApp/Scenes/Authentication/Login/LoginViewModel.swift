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
    @Published var loginSuccess = false
    @Published var needsPhoneVerification = false
    @Published var loggedInUser: User?
    
    private let authManager = AuthManager.shared
    
    func login() {
        guard validateInput() else { return }
        
        isLoading = true
        errorMessage = nil
        
        authManager.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    print("✅ Login successful! User: \(user.name)")
                    self?.loggedInUser = user
                    
                    // Check if phone is verified
                    if user.phoneVerified == true {
                        // Phone verified, navigate to home
                        self?.loginSuccess = true
                    } else {
                        // Phone not verified, navigate to verification
                        self?.needsPhoneVerification = true
                    }
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Login error: \(error.localizedDescription)")
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
