//
//  SplashView.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var calendarPageOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient.primaryGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Calendar Icon Animation
                ZStack {
                    // Back pages effect
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(-10))
                        .offset(x: -10, y: -5)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(5))
                        .offset(x: 5, y: -2)
                    
                    // Main Calendar Page
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 0) {
                            // Red/Orange Header
                            Rectangle()
                                .fill(Color.primaryOrange)
                                .frame(height: 40)
                                .cornerRadius(20, corners: [.topLeft, .topRight])
                                .overlay(
                                    HStack(spacing: 15) {
                                        Circle().fill(Color.white.opacity(0.5)).frame(width: 8, height: 8)
                                        Circle().fill(Color.white.opacity(0.5)).frame(width: 8, height: 8)
                                    }
                                )
                            
                            // Date Content
                            VStack(spacing: 5) {
                                Text(currentMonth.uppercased())
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.primaryOrange)
                                    .padding(.top, 10)
                                
                                Text(currentDay)
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(.textPrimary)
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(width: 140, height: 140)
                    .scaleEffect(isAnimating ? 1.0 : 0.8) // Start slightly smaller, but visible
                    .opacity(1) // Always visible
                }
                
                // App Name
                Text("Rezervasyon Artık Çok Kolay!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(1) // Always visible
                    .offset(y: isAnimating ? 0 : 10)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                isAnimating = true
            }
        }
    }
    
    // Helpers for current date
    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date())
    }
    
    private var currentDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: Date())
    }
}

#Preview {
    SplashView()
}
