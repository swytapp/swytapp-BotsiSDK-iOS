//
//  PaywallActionHandler.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 03.09.2025.
//

import Foundation
import Botsi

@available(iOS 15.0, *)
public enum BotsiAction: Sendable {
    case didOpen
    case didOpenURL(String)
    case didRestorePurchase(BotsiProfile)
    case didLogin
    case didClose
    case didEndTimer(id: String?)
    case didSelectProduct(BotsiProduct)
    case didPurchase(BotsiProfile)
    case didFailPurchase(BotsiProduct?, BotsiError)
    case didFailRestorePurchases(BotsiError)
    case custom(String)
}


@MainActor
@available(iOS 15.0, *)
public final class PaywallActionHandler: ObservableObject {
    private let onAction: ((BotsiAction) -> Void)?
    public let timerProvider: BotsiTimerProvider?
    
    public init(onAction: ((BotsiAction) -> Void)? = nil, timerProvider: BotsiTimerProvider? = nil) {
        self.onAction = onAction
        self.timerProvider = timerProvider
    }
    
    @MainActor
    public func handleAction(_ action: BotsiAction) {
        onAction?(action)
    }

    @MainActor
    public func handleAction(_ action: BotsiActionType, customId: String? = nil) {
        switch action {
        case .close:
            handleAction(.didClose)
        case .login:
            handleAction(.didLogin)
        case .custom:
            handleAction(.custom(customId ?? ""))
        default:
            break
        }
    }
} 
