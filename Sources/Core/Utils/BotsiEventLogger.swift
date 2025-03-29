//
//  BotsiEventLogger.swift
//  Botsi
//
//  Created by Vladyslav on 25.03.2025.
//

import Foundation

public enum BotsiLogEventType: String, Codable, Sendable {
    case initialization = "initialization"
    case userAction = "userAction"
    case userPaywallShown = "paywall_shown"
}

public struct BotsiLogEventContext: Sendable {
    public var userId: String?
    var environment: BotsiEnvironment
    
    init(userId: String? = nil,
                environment: BotsiEnvironment) {
        self.userId = userId
        self.environment = environment
    }
}

// MARK: - Core event model
public struct BotsiLogEvent: Sendable {
    public let profileId: String
    public let placementId: String?
    public let type: BotsiLogEventType
    public let name: String
    public let timestamp: TimeInterval
    public let message: String?
    public let context: BotsiLogEventContext?
    
    public init(profileId: String,
                type: BotsiLogEventType,
                name: String,
                timestamp: TimeInterval = Date().timeIntervalSince1970,
                message: String? = nil,
                context: BotsiLogEventContext? = nil,
                placementId: String? = nil
    ) {
        self.profileId = profileId
        self.type = type
        self.name = name
        self.timestamp = timestamp
        self.message = message
        self.context = context
        self.placementId = placementId
    }
}

public protocol EventLoggerPort: Sendable {
    func logEvent(_ event: BotsiLogEvent) async
}

public protocol BotsiEventSenderPort: Sendable {
    func sendEvent(_ event: BotsiLogEvent) async throws
}

// MARK: - Core implementation
public final class BotsiEventLogger: EventLoggerPort {
    private let eventSender: BotsiEventSenderPort
    private let globalContext: BotsiLogEventContext
    private let eventQueue = DispatchQueue(label: "com.botsiEventLogger.queue")

    public init(
        eventSender: BotsiEventSenderPort,
        initialContext: BotsiLogEventContext
    ) {
        self.eventSender = eventSender
        self.globalContext = initialContext
    }
    
    public func logEvent(_ event: BotsiLogEvent) async {
        do {
            try await withCheckedThrowingContinuation { continuation in
                eventQueue.async {
                    Task {
                        do {
                            try await self.eventSender.sendEvent(event)
                            continuation.resume(returning: ())
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                }
            }
        } catch {
            print("Failed to send event: \(error)")
        }
    }
}

public final class BotsiEventSender: BotsiEventSenderPort {
    private let sendEventFunction: @Sendable (BotsiLogEvent) async throws -> Void
    
    public init(sendEventFunction: @Sendable @escaping (BotsiLogEvent) async throws -> Void) {
        self.sendEventFunction = sendEventFunction
    }
    
    public func sendEvent(_ event: BotsiLogEvent) async throws {
        try await sendEventFunction(event)
    }
}

public class BotsiEventLoggerFactory {
    public static func createLoggerWithContext(
        initialContext: BotsiLogEventContext,
        sendEventFunction: @Sendable @escaping (BotsiLogEvent) async throws -> Void
    ) -> EventLoggerPort {
        let sender = BotsiEventSender(sendEventFunction: sendEventFunction)
        return BotsiEventLogger(eventSender: sender, initialContext: initialContext)
    }
}

extension BotsiEventLoggerFactory {}

