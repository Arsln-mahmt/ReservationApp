//
//  VoiceAssistantChatView.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 29.11.2025.
//

import SwiftUI

struct VoiceAssistantChatView: View {
    @StateObject private var viewModel = VoiceAssistantViewModel()
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var showLoginRequired = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Messages ScrollView
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                                
                                // Processing indicator
                                if viewModel.isProcessing {
                                    ProcessingIndicator()
                                }
                            }
                            .padding()
                        }
                        .onChange(of: viewModel.messages.count) { _, _ in
                            if let lastMessage = viewModel.messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Input area
                    inputArea
                }
            }
            .navigationTitle("Sesli Asistan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        viewModel.stopSpeaking()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.resetConversation()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.primaryOrange)
                    }
                }
            }
            .alert("Giriş Yapmanız Gerekiyor", isPresented: $showLoginRequired) {
                Button("Giriş Yap", role: .none) {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NotificationCenter.default.post(name: .showLoginFromVoiceAssistant, object: nil)
                    }
                }
                Button("İptal", role: .cancel) {}
            } message: {
                Text("Sesli asistan özelliğini kullanmak için lütfen önce giriş yapın.")
            }
        }
    }
    
    // MARK: - Input Area
    private var inputArea: some View {
        VStack(spacing: 12) {
            // Recording indicator
            if viewModel.isRecording {
                HStack(spacing: 8) {
                    RecordingWaveIndicator()
                    
                    Text("Dinliyorum...")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding(.vertical, 8)
            }
            
            // Microphone button
            HStack {
                Spacer()
                
                Button(action: {
                    handleMicrophoneButtonTap()
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isRecording ? 
                                  LinearGradient(colors: [.red, .red], startPoint: .top, endPoint: .bottom) :
                                  LinearGradient.primaryGradient
                            )
                            .frame(width: 70, height: 70)
                            .shadow(color: .primaryOrange.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
                .disabled(viewModel.isProcessing)
                .scaleEffect(viewModel.isRecording ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: viewModel.isRecording)
                
                Spacer()
            }
            .padding(.bottom, 8)
        }
        .padding()
        .background(Color.bgPrimary)
        .background(Color.bgPrimary.ignoresSafeArea(edges: .bottom))
    }
    
    // MARK: - Actions
    private func handleMicrophoneButtonTap() {
        // Check if user is logged in with valid UID
        guard let user = authManager.currentUser, !user.uid.isEmpty else {
            showLoginRequired = true
            return
        }
        
        let userId = user.uid
        print("🎤 Voice Assistant - User ID: \(userId)")
        
        if viewModel.isRecording {
            // Stop and send
            viewModel.stopRecordingAndSend(userId: userId)
        } else {
            // Start recording
            viewModel.startRecording()
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: VoiceMessage
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.body)
                    .foregroundColor(message.sender == .user ? .white : .textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.sender == .user ?
                        LinearGradient.primaryGradient :
                        LinearGradient(colors: [Color.bgCard, Color.bgCard], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(message.sender == .assistant ? Color.gray.opacity(0.2) : Color.clear, lineWidth: 1)
                    )
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 4)
            
            if message.sender == .assistant {
                Spacer()
            }
        }
    }
}

// MARK: - Processing Indicator
struct ProcessingIndicator: View {
    @State private var animationAmount: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.primaryOrange)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationAmount)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animationAmount
                    )
            }
        }
        .padding()
        .onAppear {
            animationAmount = 1.5
        }
    }
}

// MARK: - Recording Wave Indicator
struct RecordingWaveIndicator: View {
    @State private var animationAmount: CGFloat = 1
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.red)
                    .frame(width: 4)
                    .frame(height: animationAmount * CGFloat.random(in: 10...30))
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(index) * 0.1),
                        value: animationAmount
                    )
            }
        }
        .onAppear {
            animationAmount = 1.5
        }
    }
}

#Preview {
    VoiceAssistantChatView()
        .environmentObject(AuthManager.shared)
}



