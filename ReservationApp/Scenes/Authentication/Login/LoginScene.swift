//
//  LoginScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct LoginScene: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            LoginUI(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $viewModel.needsPhoneVerification) {
            if let user = viewModel.loggedInUser {
                PhoneVerificationScene(
                    phoneNumber: user.phoneNumber ?? "",
                    userId: user.uid
                )
            }
        }
        .onChange(of: viewModel.loginSuccessId) { _, newValue in
            if newValue != nil, let user = viewModel.loggedInUser {
                print("🔄 Login success detected, navigating...")
                
                // Update app environment
                appEnvironment.currentUser = user
                appEnvironment.isAuthenticated = true
                appEnvironment.userType = user.userType
                
                // Update auth manager
                authManager.currentUser = user
                authManager.isAuthenticated = true
                
                // Close the login sheet
                dismiss()
                
                // Navigate to appropriate screen
                switch user.userType {
                case .customer:
                    print("👤 Navigating to customer main app")
                    sceneDelegate.navigateTo(.mainApp)
                case .business:
                    print("🏢 Navigating to business dashboard")
                    sceneDelegate.navigateTo(.businessDashboard)
                }
            }
        }
    }
}

#Preview {
    LoginScene()
}
