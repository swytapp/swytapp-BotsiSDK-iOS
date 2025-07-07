//
//  BotsiDelegateEnvironmentKey.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 19.06.2025.
//

import SwiftUI

struct BotsiPaywallDelegateKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: BotsiPaywallDelegate? = nil
}

extension EnvironmentValues {
    var paywallDelegate: BotsiPaywallDelegate? {
        get { self[BotsiPaywallDelegateKey.self] }
        set { self[BotsiPaywallDelegateKey.self] = newValue }
    }
}
