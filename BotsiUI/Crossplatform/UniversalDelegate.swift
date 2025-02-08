//
//  File.swift
//  Botsi
//
//  Created by Aleksey Goncharov on 14.11.2024.
//

#if canImport(UIKit)

import Botsi
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension BotsiUI {
    public static var universalDelagate: BotsiPaywallControllerDelegate?

    package static func paywallControllerWithUniversalDelegate(
        _ paywallConfiguration: PaywallConfiguration,
        showDebugOverlay: Bool = false
    ) throws -> BotsiPaywallController {
        guard BotsiUI.isActivated else {
            let err = BotsiUIError.botsiNotActivatedError
            Log.ui.error("BotsiUI paywallController(for:) error: \(err)")
            throw err
        }

        guard let delegate = BotsiUI.universalDelagate else {
            Log.ui.error("BotsiUI delegateIsNotRegestired")
            throw BotsiError(BotsiUI.PluginError.delegateIsNotRegestired)
        }

        return BotsiPaywallController(
            paywallConfiguration: paywallConfiguration,
            delegate: delegate,
            showDebugOverlay: showDebugOverlay
        )
    }
}

#endif
