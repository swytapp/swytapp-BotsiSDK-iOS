//
//  BotsiPaywallControllerDelegate.swift
//
//
//  Created by Alexey Goncharov on 27.1.23..
//

import Botsi
import Foundation

/// BotsiUI is a module intended to display paywalls created with the Paywall Builder.
/// To make full use of this functionality, you need to install an additional library, as well as make additional setups in the Botsi Dashboard.
/// You can find more information in the corresponding section of [our documentation](https://adapty.io/docs/3.0/adapty-paywall-builder).
public enum BotsiUI {}

public extension BotsiUI {
    struct Configuration: Sendable {
        public static let `default` = Configuration(mediaCacheConfiguration: nil)

        /// Represents the Media Cache configuration used in BotsiUI
        let mediaCacheConfiguration: MediaCacheConfiguration?

        public init(
            mediaCacheConfiguration: MediaCacheConfiguration?
        ) {
            self.mediaCacheConfiguration = mediaCacheConfiguration
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public protocol BotsiTagResolver: Sendable {
    func replacement(for tag: String) -> String?
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public protocol BotsiTimerResolver: Sendable {
    func timerEndAtDate(for timerId: String) -> Date
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension BotsiUI {
    /// This enum describes user initiated actions.
    enum Action {
        /// User pressed Close Button
        case close
        /// User pressed any button with URL
        case openURL(url: URL)
        /// User pressed any button with custom action (e.g. login)
        case custom(id: String)
    }
}

#if canImport(UIKit)

import UIKit

/// Implement this protocol to respond to different events happening inside the purchase screen.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public protocol BotsiPaywallControllerDelegate: AnyObject {
    /// If user performs an action process, this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``BotsiPaywallController`` within which the event occurred.
    ///     - action: an ``BotsiUI.Action`` value.
    func paywallController(
        _ controller: BotsiPaywallController,
        didPerform action: BotsiUI.Action
    )

    /// If product was selected for purchase (by user or by system), this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``BotsiPaywallController`` within which the event occurred.
    ///     - product: an ``BotsiPaywallProduct`` which was selected.
    func paywallController(
        _ controller: BotsiPaywallController,
        didSelectProduct product: BotsiPaywallProductWithoutDeterminingOffer
    )

    /// If user initiates the purchase process, this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``BotsiPaywallController`` within which the event occurred.
    ///     - product: an ``BotsiPaywallProduct`` of the purchase.
    func paywallController(
        _ controller: BotsiPaywallController,
        didStartPurchase product: BotsiPaywallProduct
    )

    /// This method is invoked when a successful purchase is made.
    ///
    /// The default implementation is simply dismissing the controller:
    /// ```
    /// controller.dismiss(animated: true)
    /// ```
    /// - Parameters:
    ///   - controller: an ``BotsiPaywallController`` within which the event occurred.
    ///   - product: an ``BotsiPaywallProduct`` of the purchase.
    ///   - purchaseResult: an ``BotsiPurchaseResult`` object containing up to date information about successful purchase.
    func paywallController(
        _ controller: BotsiPaywallController,
        didFinishPurchase product: BotsiPaywallProduct,
        purchaseResult: BotsiPurchaseResult
    )

    /// This method is invoked when the purchase process fails.
    /// - Parameters:
    ///   - controller: an ``BotsiPaywallController`` within which the event occurred.
    ///   - product: an ``BotsiPaywallProduct`` of the purchase.
    ///   - error: an ``BotsiError`` object representing the error.
    func paywallController(
        _ controller: BotsiPaywallController,
        didFailPurchase product: BotsiPaywallProduct,
        error: BotsiError
    )

    /// If user initiates the restore process, this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``BotsiPaywallController`` within which the event occurred.
    func paywallControllerDidStartRestore(_ controller: BotsiPaywallController)

    /// This method is invoked when a successful restore is made.
    ///
    /// Check if the ``BotsiProfile`` object contains the desired access level, and if so, the controller can be dismissed.
    /// ```
    /// controller.dismiss(animated: true)
    /// ```
    ///
    /// - Parameters:
    ///   - controller: an ``BotsiPaywallController`` within which the event occurred.
    ///   - profile: an ``BotsiProfile`` object containing up to date information about the user.
    func paywallController(
        _ controller: BotsiPaywallController,
        didFinishRestoreWith profile: BotsiProfile
    )

    /// This method is invoked when the restore process fails.
    /// - Parameters:
    ///   - controller: an ``BotsiPaywallController`` within which the event occurred.
    ///   - error: an ``BotsiError`` object representing the error.
    func paywallController(
        _ controller: BotsiPaywallController,
        didFailRestoreWith error: BotsiError
    )

    /// This method will be invoked in case of errors during the screen rendering process.
    /// - Parameters:
    ///   - controller: an ``ABotsiPaywallController`` within which the event occurred.
    ///   - error: an ``BotsiError`` object representing the error.
    func paywallController(
        _ controller: BotsiPaywallController,
        didFailRenderingWith error: BotsiError
    )

    /// This method is invoked in case of errors during the products loading process.
    /// - Parameters:
    ///   - controller: an ``BotsiPaywallController`` within which the event occurred.
    ///   - error: an ``BotsiError`` object representing the error.
    /// - Returns: Return `true`, if you want to retry products fetching.
    func paywallController(
        _ controller: BotsiPaywallController,
        didFailLoadingProductsWith error: BotsiError
    ) -> Bool

    /// This method is invoked if there was a propblem with loading a subset of paywall's products.
    /// - Parameters:
    ///   - controller: an ``BotsiPaywallController`` within which the event occurred.
    ///   - failedIds: an array with product ids which was failed to load.
    /// - Returns: Return `true`, if you want to retry products fetching.
    func paywallController(
        _ controller: BotsiPaywallController,
        didPartiallyLoadProducts failedIds: [String]
    )
}

#endif

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public protocol BotsiObserverModeResolver: Sendable {
    func observerMode(
        didInitiatePurchase product: BotsiPaywallProduct,
        onStartPurchase: @escaping () -> Void,
        onFinishPurchase: @escaping () -> Void
    )
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public extension BotsiUI {
    internal static var isActivated: Bool = false
    internal static var isObserverModeEnabled: Bool = false

    /// Use this method to initialize the BotsiUI SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)` right after `Botsi.activate()`.
    ///
    /// - Parameter builder: `BotsiUI.Configuration` which allows to configure BotsiUI SDK
    static func activate(configuration: BotsiUI.Configuration = .default) async throws {
#if canImport(UIKit)
        let sdk: Botsi
        do {
            sdk = try await Botsi.activatedSDK
        } catch {
            let err = BotsiUIError.botsiNotActivatedError
            Log.ui.error("BotsiUI activate error: \(err)")
            throw err
        }

        guard !BotsiUI.isActivated else {
            let err = BotsiUIError.activateOnceError
            Log.ui.warn("BotsiUI activate error: \(err)")

            throw err
        }
        BotsiUI.isActivated = true
        BotsiUI.isObserverModeEnabled = await sdk.observerMode

        BotsiUI.configureMediaCache(configuration.mediaCacheConfiguration ?? .default)
        ImageUrlPrefetcher.shared.initialize()

        Log.ui.info("BotsiUI activated with \(configuration)")
#else
        throw BotsiUIError.platformNotSupported
#endif
    }
}

#if canImport(UIKit)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public extension BotsiUI {
    /// If you are using the [Paywall Builder](https://adapty.io/docs/3.0/adapty-paywall-builder), you can use this method to get a configuration object for your paywall.
    ///
    /// - Parameters:
    ///   - forPaywall: the ``BotsiPaywall`` for which you want to get a configuration.
    ///   - loadTimeout: the `TimeInterval` value which limits the request time. Cached or Fallback result will be returned in case of timeout exeeds.
    ///   - products: optional ``BotsiPaywallProducts`` array. Pass this value in order to optimize the display time of the products on the screen. If you pass `nil`, ``BotsiUI`` will automatically fetch the required products.
    ///   - observerModeResolver: if you are going to use BotsiUI in Observer Mode, pass the resolver function here.
    ///   - tagResolver: if you are going to use custom tags functionality, pass the resolver function here.
    ///   - timerResolver: if you are going to use custom timers functionality, pass the resolver function here.
    /// - Returns: an ``BotsiPaywallConfiguration`` object.
    static func getPaywallConfiguration(
        forPaywall paywall: BotsiPaywall,
        loadTimeout: TimeInterval? = nil,
        products: [BotsiPaywallProduct]? = nil,
        observerModeResolver: BotsiObserverModeResolver? = nil,
        tagResolver: BotsiTagResolver? = nil,
        timerResolver: BotsiTimerResolver? = nil
    ) async throws -> PaywallConfiguration {
        guard BotsiUI.isActivated else {
            let err = BotsiUIError.botsiNotActivatedError
            Log.ui.error("BotsiUI getViewConfiguration error: \(err)")

            throw err
        }

        let viewConfiguration = try await Botsi.getViewConfiguration(
            paywall: paywall,
            loadTimeout: loadTimeout
        )

        return PaywallConfiguration(
            logId: Log.stamp,
            paywall: paywall,
            viewConfiguration: viewConfiguration,
            products: products,
            observerModeResolver: observerModeResolver,
            tagResolver: tagResolver,
            timerResolver: timerResolver
        )
    }

    /// Right after receiving ``BotsiUI.ViewConfiguration``, you can create the corresponding ``BotsiPaywallController`` to present it afterwards.
    ///
    /// - Parameters:
    ///   - viewConfiguration: an ``BotsiUI.LocalizedViewConfiguration`` object containing information about the visual part of the paywall. To load it, use the ``BotsiUI.getViewConfiguration(paywall:locale:)`` method.
    ///   - delegate: the object that implements the ``BotsiPaywallControllerDelegate`` protocol. Use it to respond to different events happening inside the purchase screen.
    /// - Returns: an ``BotsiPaywallController`` object, representing the requested paywall screen.
    static func paywallController(
        with paywallConfiguration: PaywallConfiguration,
        delegate: BotsiPaywallControllerDelegate,
        showDebugOverlay: Bool = false
    ) throws -> BotsiPaywallController {
        guard BotsiUI.isActivated else {
            let err = BotsiUIError.botsiNotActivatedError
            Log.ui.error("BotsiUI paywallController(for:) error: \(err)")
            throw err
        }

        return BotsiPaywallController(
            paywallConfiguration: paywallConfiguration,
            delegate: delegate,
            showDebugOverlay: showDebugOverlay
        )
    }
}
#endif
