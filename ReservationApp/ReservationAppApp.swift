//
//  ReservationAppApp.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI
import FirebaseCore

@main
struct ReservationAppApp: App {
    // Connect AppDelegate to initialize Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var sceneDelegate = SceneDelegate.shared
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var appEnvironment = AppEnvironment.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch sceneDelegate.currentScene {
                case .splash:
                    SplashScene()
                        .onAppear {
                            checkAuthenticationState()
                        }
                case .authentication:
                    LoginScene()
                case .customerHome:
                    CustomerHomeScene()
                case .businessDashboard:
                    BusinessDashboardScene()
                    
                }
            }
            .environmentObject(sceneDelegate)
            .environmentObject(appEnvironment)
            .environmentObject(authManager)
        }
    }
    
    // Check authentication and navigate to appropriate screen
    private func checkAuthenticationState() {
        // Show splash for 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if authManager.isAuthenticated, let user = authManager.currentUser {
                appEnvironment.isAuthenticated = true
                appEnvironment.currentUser = user
                appEnvironment.userType = user.userType
                
                // Navigate based on user type
                if user.userType == .business {
                    sceneDelegate.navigateTo(.businessDashboard)
                } else {
                    sceneDelegate.navigateTo(.customerHome)
                }
            } else {
                // Not authenticated, go to login
                sceneDelegate.navigateTo(.authentication)
            }
        }
    }
}
