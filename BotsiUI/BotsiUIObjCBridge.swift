//
//  BotsiUIObjCBridge.swift
//  Botsi
//
//  Created by Bohdan Markevych on 15.12.2025.
//

import Foundation
import SwiftUI
import UIKit
import Botsi

@objc public enum BotsiObjCActionType: Int {
    case didOpen
    case didOpenURL
    case didRestorePurchase
    case didLogin
    case didClose
    case didEndTimer
    case didSelectProduct
    case didPurchase
    case didFailPurchase
    case didFailRestorePurchases
    case custom
}

@available(iOS 15.0, *)
@objc public class BotsiObjCAction: NSObject {
    
    @objc public let type: BotsiObjCActionType
    
    // Associated values as optional properties
    @objc public let url: String?
    @objc public let profile: BotsiObjCProfile?
    @objc public let timerId: String?
    @objc public let product: BotsiObjCProduct?
    @objc public let error: BotsiObjCError?
    @objc public let customValue: String?
    
    private init(
        type: BotsiObjCActionType,
        url: String? = nil,
        profile: BotsiObjCProfile? = nil,
        timerId: String? = nil,
        product: BotsiObjCProduct? = nil,
        error: BotsiObjCError? = nil,
        customValue: String? = nil
    ) {
        self.type = type
        self.url = url
        self.profile = profile
        self.timerId = timerId
        self.product = product
        self.error = error
        self.customValue = customValue
        super.init()
    }
    
    // Convenience initializer from Swift enum
    convenience init(_ action: BotsiAction) {
        switch action {
        case .didOpen:
            self.init(type: .didOpen)
            
        case .didOpenURL(let url):
            self.init(type: .didOpenURL, url: url)
            
        case .didRestorePurchase(let profile):
            self.init(type: .didRestorePurchase, profile: BotsiObjCProfile.fromSwift(swift: profile))
            
        case .didLogin:
            self.init(type: .didLogin)
            
        case .didClose:
            self.init(type: .didClose)
            
        case .didEndTimer(let timerId):
            self.init(type: .didEndTimer, timerId: timerId)
            
        case .didSelectProduct(let product):
            self.init(type: .didSelectProduct, product: BotsiObjCProduct.fromSwift(swift: product))
            
        case .didPurchase(let profile):
            self.init(type: .didPurchase, profile: BotsiObjCProfile.fromSwift(swift: profile))
            
        case .didFailPurchase(let product, let error):
            self.init(
                type: .didFailPurchase,
                product: product != nil ? BotsiObjCProduct.fromSwift(swift: product!) : nil,
                error: BotsiObjCError.fromSwift(swift: error)
            )
            
        case .didFailRestorePurchases(let error):
            self.init(
                type: .didFailRestorePurchases,
                error: BotsiObjCError.fromSwift(swift: error)
            )
            
        case .custom(let value):
            self.init(type: .custom, customValue: value)
        }
    }
}

@available(iOS 15.0, *)
@objc public class BotsiUIObjCBridge: NSObject {
    
    @MainActor @objc public static func presentBotsiPaywall(
        from viewController: UIViewController,
        paywall: BotsiObjCPaywall?,
        builder: Data?,
        timerProvider: BotsiTimerProvider?,
        onAction: @escaping @Sendable (BotsiObjCAction) -> Void,
        onUIError: @escaping @Sendable (BotsiObjCError) -> Void,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        viewController.presentBotsiPaywall(
            paywall: paywall?.swiftPaywall,
            builder: builder,
            timerProvider: timerProvider,
            onAction: {action in
                onAction(BotsiObjCAction(action))
            },
            onUIError: { error in
                onUIError(BotsiObjCError.fromSwift(swift: error))
            },
            animated: animated,
            completion: completion,
        )
    }
    
}
