//
//  VoiceAssistantViewModel.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 29.11.2025.
//

import Foundation
import AVFoundation
import Combine

class VoiceAssistantViewModel: ObservableObject {
    @Published var messages: [VoiceMessage] = []
    @Published var isRecording = false
    @Published var isProcessing = false
    @Published var conversationId: String = UUID().uuidString
    
    private let voiceService = VoiceServiceManager.shared
    private let audioRecorder = AudioRecorderManager()
    private let synthesizer = AVSpeechSynthesizer()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupRecorderObserver()
        addWelcomeMessage()
    }
    
    private func setupRecorderObserver() {
        audioRecorder.$isRecording
            .sink { [weak self] recording in
                self?.isRecording = recording
            }
            .store(in: &cancellables)
    }
    
    private func addWelcomeMessage() {
        let welcomeText = "Merhaba! Ben sesli randevu asistanınızım. Size nasıl yardımcı olabilirim?"
        let message = VoiceMessage(sender: .assistant, text: welcomeText)
        messages.append(message)
        speakText(welcomeText)
    }
    
    // MARK: - Recording
    func startRecording() {
        audioRecorder.startRecording()
    }
    
    func stopRecordingAndSend(userId: String) {
        guard let audioURL = audioRecorder.stopRecording() else {
            return
        }
        
        // Add processing message
        isProcessing = true
        let processingMessage = VoiceMessage(sender: .user, text: "Ses kaydı işleniyor...", isProcessing: true)
        messages.append(processingMessage)
        
        // Send to backend
        voiceService.processVoiceReservation(audioURL: audioURL, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isProcessing = false
                
                // Remove processing message
                self.messages.removeAll { $0.isProcessing }
                
                switch result {
                case .success(let response):
                    // Add user's transcribed message
                    if let userText = response.cleaned_text ?? response.raw_stt {
                        let userMessage = VoiceMessage(sender: .user, text: userText)
                        self.messages.append(userMessage)
                    }
                    
                    // Add AI response
                    let aiMessage = VoiceMessage(sender: .assistant, text: response.final_answer)
                    self.messages.append(aiMessage)
                    
                    // Speak AI response
                    self.speakText(response.final_answer)
                    
                case .failure(let error):
                    let errorMessage = VoiceMessage(
                        sender: .assistant,
                        text: "Üzgünüm, bir hata oluştu: \(error.localizedDescription)"
                    )
                    self.messages.append(errorMessage)
                }
            }
        }
    }
    
    func cancelRecording() {
        audioRecorder.cancelRecording()
    }
    
    // MARK: - Text to Speech
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "tr-TR")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    // MARK: - Reset
    func resetConversation() {
        messages.removeAll()
        conversationId = UUID().uuidString
        addWelcomeMessage()
        stopSpeaking()
    }
    
    var hasPermission: Bool {
        audioRecorder.hasPermission
    }
}



