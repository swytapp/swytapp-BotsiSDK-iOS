//
//  BotsiTimeViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

// MARK: - Timer Provider Protocol
public protocol BotsiTimerProvider: Sendable {
    func timerEndDate(for timerId: String) -> Date
}

public final class BotsiTimerStorage {
    private let storageKey: String
    
    public init(key: String) {
        self.storageKey = key
    }
    
    public func getEndDate() -> Date? {
        if let timeInterval = UserDefaults.standard.value(forKey: storageKey) as? TimeInterval {
            return Date(timeIntervalSince1970: timeInterval)
        }
        return nil
    }
    
    public func saveEndDate(_ date: Date) {
        UserDefaults.standard.set(date.timeIntervalSince1970, forKey: storageKey)
    }
    
    public func clearData() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    public static func persistenceKey(for timerId: String) -> String {
        return "BotsiTimer_Persistence_\(timerId)"
    }
}

@available(iOS 15.0, *)
@MainActor
final class BotsiTimerViewModel: ObservableObject {
    
    @Published var fullText: String = ""
    @Published private(set) var hasEnded: Bool = false
    
    var style: BotsiTextStyleModel { model.style }
    var verticalOffset: String { model.verticalOffset }
    var triggerCustomAction: Bool { model.triggerCustomAction }
    var customActionID: String? { model.customActionID }
    
    private let model: BotsiTimerModel
    private let timerId: String
    private var endDate = Date() 
    private var timer: Timer?
    private let persistentStorage: BotsiTimerStorage
    private let timerProvider: BotsiTimerProvider?
    
    private static var globalTimers = [String: Date]()
    
    init(model: BotsiTimerModel, timerProvider: BotsiTimerProvider? = nil) {
        self.model = model
        self.timerId = "\(model.startText)-\(model.beforeText)-\(model.afterText)-\(model.timerMode.rawValue)"
        self.timerProvider = timerProvider
        
        let persistenceKey = BotsiTimerStorage.persistenceKey(for: timerId)
        self.persistentStorage = BotsiTimerStorage(key: persistenceKey)
        
        self.endDate = initializeTimer(at: Date())
        
        startTimer()
    }
    
    private func initializeTimer(at currentDate: Date) -> Date {
        let totalSeconds = BotsiTimerViewModel.seconds(from: model.startText)
        let duration = TimeInterval(totalSeconds)
        
        switch model.timerMode {
        case .reset:
            let endAt = Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 + duration)
            return endAt
            
        case .appLaunchReset:
            if let globalEndAt = Self.globalTimers[timerId] {
                return globalEndAt
            } else {
                let endAt = Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 + duration)
                Self.globalTimers[timerId] = endAt
                return endAt
            }
            
        case .keep:
            if let persistedEndAt = persistentStorage.getEndDate() {
                return persistedEndAt
            } else {
                let endAt = Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 + duration)
                persistentStorage.saveEndDate(endAt)
                return endAt
            }
            
        case .defined:
            guard let provider = timerProvider else {
                let endAt: Date = Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 + duration)
                return endAt
            }
            
            return provider.timerEndDate(for: timerId)
        }
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
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func triggerEndTimerAction(actionHandler: PaywallActionHandler?) {
        actionHandler?.handleAction(.endTimer(id: customActionID))
    }
    
    private func updateDisplay() {
        let currentTime = Date()
        let remaining = max(Int(endDate.timeIntervalSince(currentTime)), 0)
        
        if remaining == 0 {
            hasEnded = true
            stopTimer()
        }
        
        let formatted = BotsiTimerViewModel.format(
            seconds: remaining,
            using: model.format,
            separator: model.separator
        )
        
        let prefix = model.beforeText.isEmpty ? "" : "\(model.beforeText) "
        let suffix = model.afterText.isEmpty ? "" : " \(model.afterText)"
        fullText = "\(prefix)\(formatted)\(suffix)"
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
