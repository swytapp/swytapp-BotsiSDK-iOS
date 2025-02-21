//
//  BotsiProfile.swift
//  Botsi
//
//  Created by Vladyslav on 19.02.2025.
//

import Foundation

public struct BotsiProfile: Sendable {
    public let profileId: String
    public let customerUserId: String?
    public let accessLevels: [String: BotsiAccessLevel]
    public let subscriptions: [String: BotsiSubscription]
    public let nonSubscriptions: [String: BotsiNonSubscription]
    public let custom: [BotsiCustomEntry]
}

extension BotsiProfile: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(profileId)
        hasher.combine(customerUserId)
    }
}

extension BotsiProfile: Equatable {
    public static func == (lhs: BotsiProfile, rhs: BotsiProfile) -> Bool {
        lhs.profileId == rhs.profileId && lhs.customerUserId == rhs.customerUserId
    }
}
