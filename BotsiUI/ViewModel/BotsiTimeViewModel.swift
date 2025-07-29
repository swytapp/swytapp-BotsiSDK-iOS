//
//  BotsiTimeViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
final class BotsiTimerViewModel: ObservableObject {
    
    @Published var displayText: String = ""
    @Published var textBefore: String = ""
    @Published var textAfter: String = ""
    
    @Published var fullText: String = ""
    
    private let totalSeconds: Int
    private let format: String
    private let separator: BotsiTimerSeparator
    private var startDate: Date
    private var timer: Timer?
    private let storageKey: String
    
    init(model: BotsiTimerModel) {
        self.format = model.format
        self.separator = model.separator
        self.totalSeconds = BotsiTimerViewModel.seconds(from: model.startText)
        
        let storageKey = "botsi.timer.\(model.startText)-\(model.beforeText)-\(model.afterText)"
        self.storageKey = storageKey
        
        if let storedStartDate = UserDefaults.standard.object(forKey: storageKey) as? Date {
            self.startDate = storedStartDate
        } else {
            self.startDate = Date()
            UserDefaults.standard.set(startDate, forKey: storageKey)
        }
        
        if !model.beforeText.isEmpty {
            self.textBefore = "\(model.beforeText) "
        }
        
        if !model.afterText.isEmpty {
            self.textAfter = " \(model.afterText)"
        }
        
        startTimer()
    }
    
    private func startTimer() {
        Task { @MainActor in
            updateDisplay()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateDisplay()
            }
        }
    }
    
    private func updateDisplay() {
        let elapsed = Int(Date().timeIntervalSince(startDate))
        var remaining = max(totalSeconds - elapsed, 0)
        
        if remaining == 0 {
            startDate = Date()
            UserDefaults.standard.set(startDate, forKey: storageKey)
            remaining = totalSeconds
        }
        
        let formatted = BotsiTimerViewModel.format(
            seconds: remaining,
            using: format,
            separator: separator
        )
        
        fullText = [
            textBefore,
            formatted,
            textAfter
        ]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
    }
    
    static func seconds(from timeString: String) -> Int {
        let regex = try! NSRegularExpression(pattern: "\\d+")
        let nsString = timeString as NSString
        let matches = regex.matches(in: timeString, range: NSRange(location: 0, length: nsString.length))
        
        let numbers = matches
            .map { nsString.substring(with: $0.range) }
            .compactMap { Int($0) }
        
        let padded = Array(repeating: 0, count: max(0, 4 - numbers.count)) + numbers
        
        return padded[0] * 86400 + padded[1] * 3600 + padded[2] * 60 + padded[3]
    }
    
    static func format(seconds: Int, using format: String, separator: BotsiTimerSeparator) -> String {
        var remaining = seconds
        let days = remaining / 86400; remaining %= 86400
        let hours = remaining / 3600; remaining %= 3600
        let minutes = remaining / 60; remaining %= 60
        let secs = remaining
        
        var components: [String] = []
        if format.contains("dd") { components.append(String(format: "%02d", days)) }
        if format.contains("hh") { components.append(String(format: "%02d", hours)) }
        if format.contains("mm") { components.append(String(format: "%02d", minutes)) }
        if format.contains("ss") { components.append(String(format: "%02d", secs)) }
        
        if separator == .letter {
            var result = ""
            let letters = ["d", "h", "m", "s"]
            for (i, comp) in components.enumerated() {
                result += "\(comp)\(letters[i]) "
            }
            return result.trimmingCharacters(in: .whitespaces)
        } else {
            return components.joined(separator: separator.string)
        }
    }
}
