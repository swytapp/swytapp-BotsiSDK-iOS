//
//  PaywallActionHandler.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 03.09.2025.
//

import Foundation

@available(iOS 15.0, *)
public enum BotsiAction: Sendable {
    case didOpen
    case didOpenURL(String)
    case didRestorePurchase
    case didLogin
    case didClose
    case didEndTimer(id: String?)
    case didSelectProduct(Int)
    case didPurchase(Int)
    case didFailPurchase(Int)
    case custom(String)
}

@available(iOS 15.0, *)
public typealias BotsiActionCallback = @MainActor (BotsiAction) -> Void

@available(iOS 15.0, *)
@MainActor
public class PaywallActionHandler: ObservableObject {
    private let onAction: BotsiActionCallback?
    public let timerProvider: BotsiTimerProvider?
    @Published public var selectedProductId: Int?
    @Published public var isBottomSheetPresented: Bool = false
    
    public init(onAction: BotsiActionCallback? = nil, timerProvider: BotsiTimerProvider? = nil) {
        self.onAction = onAction
        self.timerProvider = timerProvider
    }
    
    @MainActor
    public func handleAction(_ action: BotsiAction) {
        switch action {
        case .didSelectProduct(let productId):
            selectedProductId = productId
        default:
            break
        }
        
        onAction?(action)
    }

    @MainActor
    public func handleAction(_ action: BotsiActionType, customId: String? = nil) {
        switch action {
        case .close:
            handleAction(.didClose)
        case .restore:
            handleAction(.didRestorePurchase)
        case .login:
            handleAction(.didLogin)
        case .purchaseSelected:
            guard let selectedProductId = selectedProductId else {
                handleAction(.didFailPurchase(0))
                return
            }
            handleAction(.didPurchase(selectedProductId))
        case .custom:
            handleAction(.custom(customId ?? ""))
        default:
            break
        }
    }
    
    @MainActor
    public func setBottomSheetPresented(_ show: Bool) {
        isBottomSheetPresented = show
    }
} 
