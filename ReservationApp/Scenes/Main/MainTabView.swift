//
//  MainTabView.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    @State private var shouldShowLoginFromVoice = false
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Reservations Tab
            MyReservationsScene()
                .tabItem {
                    Label(TabItem.reservations.title, systemImage: TabItem.reservations.icon)
                }
                .tag(TabItem.reservations)
            
            // Home Tab
            HomeScene()
                .tabItem {
                    Label(TabItem.home.title, systemImage: TabItem.home.icon)
                }
                .tag(TabItem.home)
            
            // Profile Tab
            ProfileScene(shouldShowLogin: $shouldShowLoginFromVoice)
                .tabItem {
                    Label(TabItem.profile.title, systemImage: TabItem.profile.icon)
                }
                .tag(TabItem.profile)
        }
        .accentColor(.primaryOrange)
        .onReceive(NotificationCenter.default.publisher(for: .showLoginFromVoiceAssistant)) { _ in
            selectedTab = .profile
            shouldShowLoginFromVoice = true
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager.shared)
        .environmentObject(AppEnvironment.shared)
}









