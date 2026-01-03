//
//  VoiceAssistantButton.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 21.12.2025.
//

import SwiftUI

// MARK: - Voice Assistant Button with Tooltip
struct VoiceAssistantButton: View {
    @Binding var showVoiceAssistant: Bool
    @State private var showTooltip = true
    @State private var isPulsing = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                
                // Tooltip bubble
                if showTooltip {
                    HStack(spacing: 8) {
                        Image(systemName: "waveform")
                            .font(.subheadline)
                            .foregroundColor(.primaryOrange)
                        
                        Text("Sesli Asistana Sor")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.bgCard)
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .padding(.trailing, 8)
                }
                
                // Floating button with pulse effect
                Button {
                    showVoiceAssistant = true
                } label: {
                    ZStack {
                        // Pulse effect
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryOrange.opacity(0.3), Color.primaryOrangeDark.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .scaleEffect(isPulsing ? 1.2 : 1.0)
                            .opacity(isPulsing ? 0 : 0.6)
                        
                        // Main button
                        Image(systemName: "mic.fill")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                LinearGradient(
                                    colors: [Color.primaryOrange, Color.primaryOrangeDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: Color.primaryOrange.opacity(0.4), radius: 12, y: 6)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            // Start pulse animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
            
            // Hide tooltip after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showTooltip = false
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.bgPrimary.ignoresSafeArea()
        VoiceAssistantButton(showVoiceAssistant: .constant(false))
    }
}
