//
//  File.swift
//  Botsi
//
//  Created by Aleksey Goncharov on 12.11.2024.
//

#if canImport(UIKit)

import Botsi
import SwiftUI
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension BotsiUI {
    @MainActor
    final class PaywallConfiguration {
        public var id: String { paywallViewModel.viewConfiguration.id }
        public var locale: String { paywallViewModel.viewConfiguration.locale }
        public var isRightToLeft: Bool { paywallViewModel.viewConfiguration.isRightToLeft }

        package let eventsHandler: BotsiEventsHandler
        package let paywallViewModel: BotsiPaywallViewModel
        package let productsViewModel: BotsiProductsViewModel
        package let actionsViewModel: BotsiUIActionsViewModel
        package let sectionsViewModel: BotsiSectionsViewModel
        package let tagResolverViewModel: BotsiTagResolverViewModel
        package let timerViewModel: BotsiTimerViewModel
        package let screensViewModel: BotsiScreensViewModel
        package let videoViewModel: BotsiVideoViewModel

        package init(
            logId: String,
            paywall: BotsiPaywallInterface,
            viewConfiguration: BotsiViewConfiguration,
            products: [BotsiPaywallProduct]?,
            observerModeResolver: BotsiObserverModeResolver?,
            tagResolver: BotsiTagResolver?,
            timerResolver: BotsiTimerResolver?
        ) {
            Log.ui.verbose("#\(logId)# init template: \(viewConfiguration.templateId), products: \(products?.count ?? 0), observerModeResolver: \(observerModeResolver != nil)")

            if BotsiUI.isObserverModeEnabled, observerModeResolver == nil {
                Log.ui.warn("In order to handle purchases in Observer Mode enabled, provide the observerModeResolver!")
            } else if !BotsiUI.isObserverModeEnabled, observerModeResolver != nil {
                Log.ui.warn("You should not pass observerModeResolver if you're using Botsi in Full Mode")
            }

            eventsHandler = BotsiEventsHandler(logId: logId)
            tagResolverViewModel = BotsiTagResolverViewModel(tagResolver: tagResolver)
            actionsViewModel = BotsiUIActionsViewModel(eventsHandler: eventsHandler)
            sectionsViewModel = BotsiSectionsViewModel(logId: logId)
            paywallViewModel = BotsiPaywallViewModel(
                eventsHandler: eventsHandler,
                paywall: paywall,
                viewConfiguration: viewConfiguration
            )
            productsViewModel = BotsiProductsViewModel(
                eventsHandler: eventsHandler,
                paywallViewModel: paywallViewModel,
                products: products,
                observerModeResolver: observerModeResolver
            )
            screensViewModel = BotsiScreensViewModel(
                eventsHandler: eventsHandler,
                viewConfiguration: viewConfiguration
            )
            timerViewModel = BotsiTimerViewModel(
                timerResolver: timerResolver ?? BotsiUIDefaultTimerResolver(),
                paywallViewModel: paywallViewModel,
                productsViewModel: productsViewModel,
                actionsViewModel: actionsViewModel,
                sectionsViewModel: sectionsViewModel,
                screensViewModel: screensViewModel
            )
            videoViewModel = BotsiVideoViewModel(eventsHandler: eventsHandler)

            productsViewModel.loadProductsIfNeeded()
        }
    }
}

#endif
