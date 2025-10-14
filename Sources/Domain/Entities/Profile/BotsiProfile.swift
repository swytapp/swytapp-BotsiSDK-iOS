//
//  BotsiProfile.swift
//  Botsi
//
//  Created by Vladyslav on 19.02.2025.
//

import Foundation

public struct BotsiProfile: Sendable, Codable {
    public let profileId: String
    public let customerUserId: String?
    public let accessLevels: [String: BotsiAccessLevel]
    public let subscriptions: [String: BotsiSubscription]
    public let nonSubscriptions: [String: BotsiNonSubscription]
    public let custom: [BotsiCustomEntry]
    public let birthday: Date?
    
    private enum CodingKeys: String, CodingKey {
        case profileId, customerUserId, accessLevels, subscriptions, nonSubscriptions, custom, birthday
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        profileId = try container.decode(String.self, forKey: .profileId)
        customerUserId = try container.decodeIfPresent(String.self, forKey: .customerUserId)
        accessLevels = try container.decode([String: BotsiAccessLevel].self, forKey: .accessLevels)
        subscriptions = try container.decode([String: BotsiSubscription].self, forKey: .subscriptions)
        nonSubscriptions = try container.decode([String: BotsiNonSubscription].self, forKey: .nonSubscriptions)
        custom = try container.decode([BotsiCustomEntry].self, forKey: .custom)
        
        if let birthdayString = try container.decodeIfPresent(String.self, forKey: .birthday) {
            birthday = try Date.parseISO8601(from: birthdayString)
        } else {
            birthday = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(profileId, forKey: .profileId)
        try container.encodeIfPresent(customerUserId, forKey: .customerUserId)
        try container.encode(accessLevels, forKey: .accessLevels)
        try container.encode(subscriptions, forKey: .subscriptions)
        try container.encode(nonSubscriptions, forKey: .nonSubscriptions)
        try container.encode(custom, forKey: .custom)
        
        if let birthday = birthday {
            try container.encode(birthday.toISO8601String(), forKey: .birthday)
        }
    }
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
