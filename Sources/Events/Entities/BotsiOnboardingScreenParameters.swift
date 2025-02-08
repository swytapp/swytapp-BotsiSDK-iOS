//
//  BotsiOnboardingScreenParameters.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

public struct BotsiOnboardingScreenParameters: Sendable {
    public let name: String?
    public let screenName: String?
    public let screenOrder: UInt
}

extension BotsiOnboardingScreenParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case name = "onboarding_name"
        case screenName = "onboarding_screen_name"
        case screenOrder = "onboarding_screen_order"
    }
}
