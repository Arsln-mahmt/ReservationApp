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
        .onChange(of: viewModel.loginSuccess) { success in
            if success, let user = viewModel.loggedInUser {
                // Update app environment
                appEnvironment.currentUser = user
                appEnvironment.isAuthenticated = true
                appEnvironment.userType = user.userType
                
                // Navigate to appropriate home screen
                switch user.userType {
                case .customer:
                    sceneDelegate.navigateTo(.customerHome)
                case .business:
                    sceneDelegate.navigateTo(.businessDashboard)
                }
            }
        }
    }
}

#Preview {
    LoginScene()
}
