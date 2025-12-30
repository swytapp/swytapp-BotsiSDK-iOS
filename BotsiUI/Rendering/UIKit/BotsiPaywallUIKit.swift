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
    ///     - onAction: Optional callback for handling paywall actions.
    ///     - onUIError: Required callback for handling UI errors.
    ///     - animated: Whether to animate the presentation.
    ///     - completion: Optional completion handler.
    func presentBotsiPaywall(
        paywall: BotsiPaywall?,
        builder: Botsi.BotsiBuilder?,
        timerProvider: BotsiTimerProvider? = nil,
        onAction: ((BotsiAction) -> Void)? = nil,
        onUIError: @escaping (BotsiUIError) -> Void,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        do {
            let paywallView = try BotsiUI.makePaywall(
                paywall: paywall,
                builder: builder,
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

