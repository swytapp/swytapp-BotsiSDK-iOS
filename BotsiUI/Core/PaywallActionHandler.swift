//
//  PaywallActionHandler.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 03.09.2025.
//

import Foundation

@available(iOS 15.0, *)
public enum PaywallAction: Sendable {
    case openURL(String)
    case action(BotsiActionType, customId: String?)
    case close
    case endTimer(id: String?)
    case selectProduct(String)
}

@available(iOS 15.0, *)
@MainActor
public class PaywallActionHandler: ObservableObject {
    private let paywall: BotsiPaywallViewModel
    public let timerProvider: BotsiTimerProvider?
    @Published public var selectedProductId: String?
    
    public init(paywall: BotsiPaywallViewModel) {
        self.paywall = paywall
        self.timerProvider = paywall.timerProvider
    }
    
    @MainActor
    public func handleAction(_ action: PaywallAction) {
        switch action {
        case .openURL(let urlString):
            paywall.openUrl(url: urlString)
        case .action(let actionType, let customId):
            switch actionType {
            case .close:
                paywall.didClose()
            case .restore:
                paywall.didTapRestore()
            case .login:
                paywall.didTapLogin()
            case .custom:
                paywall.didTapCustom(id: customId ?? "")
            }
        case .close:
            paywall.didClose()
        case .endTimer(let id):
            paywall.didEndTimer(id: id)
        case .selectProduct(let productId):
            selectedProductId = productId
        }
    }
} 
