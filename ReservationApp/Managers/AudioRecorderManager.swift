//
//  AudioRecorderManager.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 16.11.2025.
//

import Foundation
import AVFoundation
import Combine

class AudioRecorderManager: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    
    @Published var isRecording = false
    @Published var recordingURL: URL?
    @Published var hasPermission = false
    
    override init() {
        super.init()
        checkPermission()
    }
    
    // MARK: - Check Permission
    func checkPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] allowed in
            DispatchQueue.main.async {
                self?.hasPermission = allowed
            }
        }
    }
    
    // MARK: - Setup Audio Session
    private func setupAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true)
    }
    
    // MARK: - Start Recording
    func startRecording() {
        guard hasPermission else {
            print("❌ Recording permission denied")
            return
        }
        
        do {
            try setupAudioSession()
            
            // Create audio file URL using NSTemporaryDirectory
            let tempDir = NSTemporaryDirectory()
            let fileName = "voice_recording_\(UUID().uuidString).m4a"
            let audioFilename = URL(fileURLWithPath: tempDir).appendingPathComponent(fileName)
            
            print("🎤 Recording to: \(audioFilename.path)")
            print("🎤 Temp directory: \(tempDir)")
            
            // Recording settings
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 128000
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            
            if audioRecorder?.record() == true {
                isRecording = true
                recordingURL = audioFilename
                print("✅ Recording started successfully")
            } else {
                isRecording = false
                print("❌ Failed to start recording")
            }
        } catch {
            isRecording = false
            print("❌ Recording setup error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Stop Recording
    func stopRecording() -> URL? {
        guard isRecording else { return nil }
        
        audioRecorder?.stop()
        isRecording = false
        return recordingURL
    }
    
    // MARK: - Cancel Recording
    func cancelRecording() {
        audioRecorder?.stop()
        isRecording = false
        
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        
        recordingURL = nil
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorderManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            isRecording = false
        }
    }
}

