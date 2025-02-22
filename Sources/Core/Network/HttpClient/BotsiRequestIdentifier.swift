//
//  BotsiRequestIdentifier.swift
//  Botsi
//
//  Created by Vladyslav on 22.02.2025.
//

// MARK: Route for endpoint
public enum BotsiRequestIdentifier: String, Sendable {
    case activate
    case authenticate
    case logout

    case getProfile
    case createProfile = "profiles"
    case updateProfile
   
    case makePurchase
    case restorePurchases
}

public struct BotsiHTTPRequestPath: Sendable {
    var identifier: BotsiRequestIdentifier
}
