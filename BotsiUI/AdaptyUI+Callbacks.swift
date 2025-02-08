//
//  BotsiUI+Callbacks.swift
//
//
//  Created by Alexey Goncharov on 30.8.23..
//

import Botsi
import Foundation

#if canImport(UIKit) && canImport(_Concurrency) && compiler(>=5.5.2)

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension BotsiUI {
    /// Use this method to initialize the BotsiUI SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)` right after `Botsi.activate()`.
    ///
    /// - Parameter builder: `BotsiUI.Configuration` which allows to configure BotsiUI SDK
    static func activate(
        configuration: Configuration = .default,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await BotsiUI.activate(configuration: configuration)
        }
    }

    /// If you are using the [Paywall Builder](https://docs.adapty.io/docs/paywall-builder-getting-started), you can use this method to get a configuration object for your paywall.
    ///
    /// - Parameters:
    ///   - forPaywall: the ``BotsiPaywall`` for which you want to get a configuration.
    ///   - loadTimeout: the `TimeInterval` value which limits the request time. Cached or Fallback result will be returned in case of timeout exceeds.
    ///   - completion: A result containing the ``Botsi.ViewConfiguration>`` object. Use it with [BotsiUI](https://github.com/adaptyteam/AdaptySDK-iOS-VisualPaywalls.git) library.
    static func getPaywallConfiguration(
        forPaywall paywall: BotsiPaywall,
        loadTimeout: TimeInterval = 5.0,
        products: [BotsiPaywallProduct]? = nil,
        observerModeResolver: BotsiObserverModeResolver? = nil,
        tagResolver: BotsiTagResolver? = nil,
        timerResolver: BotsiTimerResolver? = nil,
        _ completion: @escaping BotsiResultCompletion<PaywallConfiguration>
    ) {
        withCompletion(completion) {
            try await BotsiUI.getPaywallConfiguration(
                forPaywall: paywall,
                loadTimeout: loadTimeout,
                products: products,
                observerModeResolver: observerModeResolver,
                tagResolver: tagResolver,
                timerResolver: timerResolver
            )
        }
    }
}

private func withCompletion(
    _ completion: BotsiErrorCompletion? = nil,
    from operation: @escaping @Sendable () async throws -> Void
) {
    Task {
        do {
            try await operation()
            await (BotsiConfiguration.callbackDispatchQueue ?? .main).async {
                completion?(nil)
            }
        } catch {
            await (BotsiConfiguration.callbackDispatchQueue ?? .main).async {
                completion?(error.asBotsiError)
            }
        }
    }
}

private func withCompletion<T: Sendable>(
    _ completion: @escaping BotsiResultCompletion<T>,
    from operation: @escaping @Sendable () async throws -> T
) {
    Task {
        do {
            let result = try await operation()
            await (BotsiConfiguration.callbackDispatchQueue ?? .main).async {
                completion(.success(result))
            }
        } catch {
            await (BotsiConfiguration.callbackDispatchQueue ?? .main).async {
                completion(.failure(error.asBotsiError))
            }
        }
    }
}

#endif
