//
//  SplashScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct SplashScene: View {
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Premium gradient background
            LinearGradient.primaryGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App logo with elegant animation
                ZStack {
                    // Outer glow circle
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 140, height: 140)
                        .blur(radius: 3)
                        .scaleEffect(scale * 1.1)
                    
                    // Main logo background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.25), .white.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(scale)
                    
                    // Icon
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 55, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(scale)
                }
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                
                // App name with elegant typography
                VStack(spacing: 8) {
                    Text("ReservationApp")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Tagline
                    Text("Rezervasyon Artık Çok Kolay")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .tracking(1)
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            // Elegant entrance animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                scale = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                opacity = 1.0
            }
        }
    }
}

#Preview {
    SplashScene()
}











