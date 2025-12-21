//
//  VoiceAssistantSheet.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 16.11.2025.
//

import SwiftUI
import AVFoundation

struct VoiceAssistantSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject private var recorder = AudioRecorderManager()
    @State private var isProcessing = false
    @State private var response: VoiceReservationResponse?
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showLoginRequired = false
    
    private let voiceService = VoiceServiceManager.shared
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    if recorder.isRecording {
                        // Recording state
                        recordingView
                    } else if isProcessing {
                        // Processing state
                        processingView
                    } else if let response = response {
                        // Response received
                        responseView(response)
                    } else {
                        // Initial state
                        initialView
                    }
                    
                    Spacer()
                    
                    // Main action button
                    actionButton
                }
                .padding(20)
            }
            .navigationTitle("Sesli Asistan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        if recorder.isRecording {
                            recorder.cancelRecording()
                        }
                        dismiss()
                    }
                }
            }
            .alert("Giriş Yapmanız Gerekiyor", isPresented: $showLoginRequired) {
                Button("Giriş Yap", role: .none) {
                    dismiss()
                    // Post notification to open login sheet from Profile tab
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NotificationCenter.default.post(name: .showLoginFromVoiceAssistant, object: nil)
                    }
                }
                Button("İptal", role: .cancel) {}
            } message: {
                Text("Sesli asistan özelliğini kullanmak için lütfen önce giriş yapın.")
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Bir hata oluştu")
            }
        }
    }
    
    // MARK: - Initial View
    private var initialView: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.primaryOrange)
            
            Text("Sesli Randevu Asistanı")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text("Mikrofon butonuna basarak konuşmaya başlayın")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Example commands
            VStack(alignment: .leading, spacing: 12) {
                Text("Örnek komutlar:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.textSecondary)
                
                ExampleCommand(text: "\"Yarın saat 15:00'da oto yıkama randevusu almak istiyorum\"")
                ExampleCommand(text: "\"Perşembe saat 10:00'da kuaför randevusu\"")
                ExampleCommand(text: "\"Bu hafta sonu spa randevusu\"")
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Recording View
    private var recordingView: some View {
        VStack(spacing: 30) {
            // Animated waveform
            RecordingWaveView()
                .frame(height: 120)
            
            Text("Dinliyorum...")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Text("Randevu detaylarınızı söyleyin")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Processing View
    private var processingView: some View {
        VStack(spacing: 30) {
            ProgressView()
                .scaleEffect(2)
                .tint(.primaryOrange)
            
            Text("İşleniyor...")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("Sesiniz analiz ediliyor")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
    }
    
    // MARK: - Response View
    private func responseView(_ response: VoiceReservationResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // AI Response
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.title)
                        .foregroundColor(.primaryOrange)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI Yanıtı")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.textSecondary)
                        
                        Text(response.final_answer)
                            .font(.body)
                            .foregroundColor(.textPrimary)
                    }
                }
                .padding()
                .background(Color.primaryOrange.opacity(0.1))
                .cornerRadius(12)
                
                // Action buttons
                if response.reservation_created == true {
                    Button(action: {
                        // Navigate to reservations
                        dismiss()
                    }) {
                        Text("Rezervasyonlarımı Gör")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient.primaryGradient)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Action Button
    private var actionButton: some View {
        VStack(spacing: 16) {
            if response != nil {
                // Try again button
                Button(action: {
                    resetState()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Yeni Kayıt")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient.primaryGradient)
                    .cornerRadius(12)
                }
            } else {
                // Microphone button
                Button(action: {
                    handleMicrophoneButtonTap()
                }) {
                    ZStack {
                        Circle()
                            .fill(recorder.isRecording ? 
                                  LinearGradient(colors: [.red, .red], startPoint: .top, endPoint: .bottom) :
                                  LinearGradient.primaryGradient
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                }
                .disabled(isProcessing)
                .scaleEffect(recorder.isRecording ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: recorder.isRecording)
                
                Text(recorder.isRecording ? "Durmak için dokun" : "Kaydetmek için dokun")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
    }
    
    // MARK: - Actions
    private func handleMicrophoneButtonTap() {
        // Check if user is logged in
        guard authManager.currentUser != nil else {
            showLoginRequired = true
            return
        }
        
        if recorder.isRecording {
            // Stop and process
            if let audioURL = recorder.stopRecording() {
                processAudio(audioURL)
            }
        } else {
            // Start recording
            recorder.startRecording()
        }
    }
    
    private func processAudio(_ audioURL: URL) {
        isProcessing = true
        
        let userId = authManager.currentUser?.uid ?? "test_user"
        
        voiceService.processVoiceReservation(audioURL: audioURL, userId: userId) { [self] result in
            DispatchQueue.main.async {
                isProcessing = false
                
                switch result {
                case .success(let voiceResponse):
                    response = voiceResponse
                    
                    // Speak the response
                    speakText(voiceResponse.final_answer)
                    
                case .failure(let error):
                    errorMessage = "Ses işlenirken bir hata oluştu: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "tr-TR")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        
        synthesizer.speak(utterance)
    }
    
    private func resetState() {
        response = nil
        errorMessage = nil
        isProcessing = false
    }
}

// MARK: - Supporting Views
struct RecordingWaveView: View {
    @State private var animationAmount: CGFloat = 1
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<5) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.red)
                    .frame(width: 8)
                    .frame(height: animationAmount * CGFloat.random(in: 20...100))
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

struct ExampleCommand: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "mic.fill")
                .font(.caption)
                .foregroundColor(.primaryOrange)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.primaryOrange)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
        }
    }
}

struct DebugRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.textSecondary)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.textPrimary)
        }
    }
}

#Preview {
    VoiceAssistantSheet()
        .environmentObject(AuthManager.shared)
}

