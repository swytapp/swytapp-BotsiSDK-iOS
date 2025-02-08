//
//  Botsi+Activate.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 22.09.2024
//

import Foundation

private let log = Log.default

extension Botsi {
    /// Use this method to initialize the Botsi SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter apiKey: You can find it in your app settings in [Botsi Dashboard](https://app.adapty.io/) *App settings* > *General*.
    /// - Parameter observerMode: A boolean value controlling [Observer mode](https://docs.adapty.io/v2.0.0/docs/observer-vs-full-mode). Turn it on if you handle purchases and subscription status yourself and use Botsi for sending subscription events and analytics
    /// - Parameter customerUserId: User identifier in your system
    public nonisolated static func activate(
        _ apiKey: String,
        observerMode: Bool = false,
        customerUserId: String? = nil
    ) async throws {
        try await activate(
            with: BotsiConfiguration
                .builder(withAPIKey: apiKey)
                .with(customerUserId: customerUserId)
                .with(observerMode: observerMode)
                .build()
        )
    }

    /// Use this method to initialize the Botsi SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter builder: `BotsiConfiguration.Builder` which allows to configure Botsi SDK
    public nonisolated static func activate(
        with builder: BotsiConfiguration.Builder
    ) async throws {
        try await activate(with: builder.build())
    }

    /// Use this method to initialize the Botsi SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter configuration: `BotsiConfiguration` which allows to configure Botsi SDK
    public static func activate(
        with configuration: BotsiConfiguration
    ) async throws {
        let stamp = Log.stamp
        let logParams: EventParameters? = [
            "observer_mode": configuration.observerMode,
            "has_customer_user_id": configuration.customerUserId != nil,
            "idfa_collection_disabled": configuration.idfaCollectionDisabled,
            "ip_address_collection_disabled": configuration.ipAddressCollectionDisabled,
        ]

        trackSystemEvent(BotsiSDKMethodRequestParameters(methodName: .activate, stamp: stamp, params: logParams))
        log.verbose("Calling Botsi activate [\(stamp)] with params: \(logParams?.description ?? "nil")")

        guard !isActivated else {
            let error = BotsiError.activateOnceError()
            trackSystemEvent(BotsiSDKMethodResponseParameters(methodName: .activate, stamp: stamp, error: error.localizedDescription))
            log.error("Botsi activate [\(stamp)] encountered an error: \(error).")
            throw error
        }

        let task = Task<Botsi, Never> { @BotsiActor in
            if let logLevel = configuration.logLevel { Botsi.logLevel = logLevel }

            await Storage.clearAllDataIfDifferent(apiKey: configuration.apiKey)

            BotsiConfiguration.callbackDispatchQueue = configuration.callbackDispatchQueue // TODO: Refactoring
            BotsiConfiguration.idfaCollectionDisabled = configuration.idfaCollectionDisabled // TODO: Refactoring
            BotsiConfiguration.ipAddressCollectionDisabled = configuration.ipAddressCollectionDisabled // TODO: Refactoring

            let environment = await Environment.instance
            let backend = Backend(with: configuration, envorinment: environment)

            Task {
                await eventsManager.set(backend: backend)
            }

            let sdk = await Botsi(
                configuration: configuration,
                backend: backend
            )

            trackSystemEvent(BotsiSDKMethodResponseParameters(methodName: .activate, stamp: stamp))
            log.info("Botsi activated successfully. [\(stamp)]")

            set(shared: sdk)

            LifecycleManager.shared.initialize()
            return sdk
        }
        set(activatingSDK: task)
        _ = await task.value
    }
}
