//
//  View+Extension.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI
import Combine

extension View {
    /// Modern card style with shadow
    func cardStyle() -> some View {
        self
            .background(Color.bgCard)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    /// Elevated card style
    func elevatedCardStyle() -> some View {
        self
            .background(Color.bgCard)
            .cornerRadius(20)
            .shadow(color: Color.primaryOrange.opacity(0.15), radius: 15, x: 0, y: 8)
    }
    
    /// Primary button with gradient
    func primaryButtonStyle() -> some View {
        self
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(LinearGradient.primaryGradient)
            .cornerRadius(12)
            .contentShape(Rectangle())
            .shadow(color: Color.primaryOrange.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    /// Secondary button (outlined)
    func secondaryButtonStyle() -> some View {
        self
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.primaryOrange)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primaryOrange, lineWidth: 2)
            )
            .contentShape(Rectangle())
    }
    
    /// Text field style
    func textFieldStyle() -> some View {
        self
            .padding()
            .background(Color.bgSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.textLight.opacity(0.3), lineWidth: 1)
            )
    }
    
    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), 
                                       to: nil, from: nil, for: nil)
    }
    
    /// Shimmer effect for loading
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}
