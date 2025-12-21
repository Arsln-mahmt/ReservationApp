//
//  VoiceMessage.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 29.11.2025.
//

import Foundation

enum MessageSender {
    case user
    case assistant
}

struct VoiceMessage: Identifiable {
    let id: UUID
    let sender: MessageSender
    let text: String
    let timestamp: Date
    let isProcessing: Bool
    
    init(id: UUID = UUID(), sender: MessageSender, text: String, timestamp: Date = Date(), isProcessing: Bool = false) {
        self.id = id
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
        self.isProcessing = isProcessing
    }
}



