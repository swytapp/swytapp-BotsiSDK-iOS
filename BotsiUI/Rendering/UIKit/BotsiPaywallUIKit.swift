//
//  BotsiPaywallUIKit.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 17.06.2025.
//

import UIKit
import SwiftUI
import Botsi

@available(iOS 15.0, *)
@MainActor
public extension UIViewController {
    /// Presents a paywall modally when called.
    ///
    /// - Parameters:
    ///     - paywall: BotsiPaywall object containing paywall object.
    ///     - builder: JSON data containing paywall structure.
    ///     - timerProvider: Optional timer provider for countdown functionality.
    ///     - purchaseDelegate: Optional delegate to override default purchase and restore behavior.
    ///       Use this to integrate with RevenueCat or other payment processors.
    ///     - onAction: Optional callback for handling paywall actions.
    ///     - onUIError: Required callback for handling UI errors.
    ///     - animated: Whether to animate the presentation.
    ///     - completion: Optional completion handler.
    ///
    /// - Example with custom purchase delegate:
    /// ```swift
    /// let delegate = MyRevenueCatDelegate()
    ///
    /// viewController.presentBotsiPaywall(
    ///     paywall: paywall,
    ///     builder: builder,
    ///     purchaseDelegate: delegate,
    ///     onAction: { action in
    ///         // Handle actions
    ///     },
    ///     onUIError: { error in
    ///         // Handle errors
    ///     }
    /// )
    /// ```
    func presentBotsiPaywall(
        paywall: BotsiPaywall?,
        builder: Botsi.BotsiBuilder?,
        timerProvider: BotsiTimerProvider? = nil,
        purchaseDelegate: BotsiPurchaseDelegate? = nil,
        onAction: ((BotsiAction) -> Void)? = nil,
        onUIError: @escaping (BotsiUIError) -> Void,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        do {
            let paywallView = try BotsiUI.makePaywall(
                paywall: paywall,
                builder: builder,
                purchaseDelegate: purchaseDelegate,
                onAction: onAction,
                timerProvider: timerProvider
            )
            
            let hostingController = UIHostingController(rootView: paywallView)
            hostingController.modalPresentationStyle = .fullScreen
            
            present(hostingController, animated: animated, completion: completion)
            
        } catch {
            if let uiError = error as? BotsiUIError {
                onUIError(uiError)
            } else {
                onUIError(BotsiUIError.contentParsingError)
            }
        }
    }
}

