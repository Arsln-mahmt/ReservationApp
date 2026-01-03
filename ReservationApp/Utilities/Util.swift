//
//  Util.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation

struct Util {
    /// Format date
    static func formatDate(_ date: Date, format: String = "dd/MM/yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    /// Format time
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    /// Generate time slots (e.g., 09:00, 09:30, 10:00, ...)
    static func generateTimeSlots(startHour: Int = 9, 
                                  endHour: Int = 18, 
                                  interval: Int = 30) -> [String] {
        var slots: [String] = []
        var currentHour = startHour
        var currentMinute = 0
        
        while currentHour < endHour || (currentHour == endHour && currentMinute == 0) {
            let timeString = String(format: "%02d:%02d", currentHour, currentMinute)
            slots.append(timeString)
            
            currentMinute += interval
            if currentMinute >= 60 {
                currentMinute = 0
                currentHour += 1
            }
        }
        
        return slots
    }
    
    /// Email validation
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Phone validation
    static func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9]{10,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
}
