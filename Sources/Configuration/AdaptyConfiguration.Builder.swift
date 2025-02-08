//
//  BotsiConfiguration.Builder.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.04.2024.
//

import Foundation

extension BotsiConfiguration {
    fileprivate init(with builder: BotsiConfiguration.Builder) {
        let apiKey = builder.apiKey
        assert(apiKey.count >= 41 && apiKey.starts(with: "public_live"), "It looks like you have passed the wrong apiKey value to the Botsi SDK.")

        let defaultValue = BotsiConfiguration.default

        let defaultBackend = switch builder.serverCluster ?? .default {
        case .eu:
            Backend.URLs.euPublicEnvironment
        default:
            Backend.URLs.defaultPublicEnvironment
        }

        self.init(
            apiKey: apiKey,
            customerUserId: builder.customerUserId,
            observerMode: builder.observerMode ?? defaultValue.observerMode,
            idfaCollectionDisabled: builder.idfaCollectionDisabled ?? defaultValue.idfaCollectionDisabled,
            ipAddressCollectionDisabled: builder.ipAddressCollectionDisabled ?? defaultValue.ipAddressCollectionDisabled,
            callbackDispatchQueue: builder.callbackDispatchQueue,
            backend: .init(
                baseUrl: builder.backendBaseUrl ?? defaultBackend.baseUrl,
                fallbackUrl: builder.backendFallbackBaseUrl ?? defaultBackend.fallbackUrl,
                configsUrl: builder.backendConfigsBaseUrl ?? defaultBackend.configsUrl,
                proxy: builder.backendProxy ?? defaultBackend.proxy
            ),
            logLevel: builder.logLevel,
            crossPlatformSDK: builder.crossPlatformSDK
        )
    }

    public static func builder(withAPIKey apiKey: String) -> BotsiConfiguration.Builder {
        .init(
            apiKey: apiKey,
            customerUserId: nil,
            observerMode: nil,
            idfaCollectionDisabled: nil,
            ipAddressCollectionDisabled: nil,
            callbackDispatchQueue: nil,
            serverCluster: nil,
            backendBaseUrl: nil,
            backendFallbackBaseUrl: nil,
            backendConfigsBaseUrl: nil,
            backendProxy: nil,
            logLevel: nil,
            crossPlatformSDK: nil
        )
    }
}

public extension BotsiConfiguration {
    final class Builder {
        public private(set) var apiKey: String
        public private(set) var customerUserId: String?
        public private(set) var observerMode: Bool?
        public private(set) var idfaCollectionDisabled: Bool?
        public private(set) var ipAddressCollectionDisabled: Bool?
        public private(set) var callbackDispatchQueue: DispatchQueue?

        public private(set) var serverCluster: ServerCluster?
        public private(set) var backendBaseUrl: URL?
        public private(set) var backendFallbackBaseUrl: URL?
        public private(set) var backendConfigsBaseUrl: URL?
        public private(set) var backendProxy: (host: String, port: Int)?

        public private(set) var logLevel: BotsiLog.Level?

        package private(set) var crossPlatformSDK: (name: String, version: String)?

        init(
            apiKey: String,
            customerUserId: String?,
            observerMode: Bool?,
            idfaCollectionDisabled: Bool?,
            ipAddressCollectionDisabled: Bool?,
            callbackDispatchQueue: DispatchQueue?,
            serverCluster: ServerCluster?,
            backendBaseUrl: URL?,
            backendFallbackBaseUrl: URL?,
            backendConfigsBaseUrl: URL?,
            backendProxy: (host: String, port: Int)?,
            logLevel: BotsiLog.Level?,
            crossPlatformSDK: (name: String, version: String)?
        ) {
            self.apiKey = apiKey
            self.customerUserId = customerUserId
            self.observerMode = observerMode
            self.idfaCollectionDisabled = idfaCollectionDisabled
            self.ipAddressCollectionDisabled = ipAddressCollectionDisabled
            self.callbackDispatchQueue = callbackDispatchQueue
            self.serverCluster = serverCluster ?? .default
            self.backendBaseUrl = backendBaseUrl
            self.backendFallbackBaseUrl = backendFallbackBaseUrl
            self.backendConfigsBaseUrl = backendConfigsBaseUrl
            self.backendProxy = backendProxy
            self.logLevel = logLevel
            self.crossPlatformSDK = crossPlatformSDK
        }

        /// Call this method to get the ``BotsiConfiguration`` object.
        public func build() -> BotsiConfiguration {
            .init(with: self)
        }
    }
}

public extension BotsiConfiguration.Builder {
    /// - Parameter apiKey: You can find it in your app settings in [Botsi Dashboard](https://app.adapty.io/) *App settings* > *General*.
    @discardableResult
    func with(apiKey key: String) -> Self {
        apiKey = key
        return self
    }

    /// - Parameter customerUserId: User identifier in your system
    @discardableResult
    func with(customerUserId id: String?) -> Self {
        customerUserId = id
        return self
    }

    /// - Parameter observerMode: A boolean value controlling [Observer mode](https://docs.adapty.io/docs/observer-vs-full-mode/). Turn it on if you handle purchases and subscription status yourself and use Botsi for sending subscription events and analytics
    @discardableResult
    func with(observerMode mode: Bool) -> Self {
        observerMode = mode
        return self
    }

    /// - Parameter idfaCollectionDisabled: A boolean value controlling idfa collection logic
    @discardableResult
    func with(idfaCollectionDisabled value: Bool) -> Self {
        idfaCollectionDisabled = value
        return self
    }

    /// - Parameter ipAddressCollectionDisabled: A boolean value controlling ip-address collection logic
    @discardableResult
    func with(ipAddressCollectionDisabled value: Bool) -> Self {
        ipAddressCollectionDisabled = value
        return self
    }

    /// - Parameter dispatchQueue: Specify the Dispatch Queue where callbacks will be executed
    @discardableResult
    func with(callbackDispatchQueue queue: DispatchQueue) -> Self {
        callbackDispatchQueue = queue
        return self
    }

    @discardableResult
    func with(serverCluster value: BotsiConfiguration.ServerCluster) -> Self {
        serverCluster = value
        return self
    }

    @discardableResult
    func with(backendBaseUrl url: URL) -> Self {
        backendBaseUrl = url
        return self
    }

    @discardableResult
    func with(backendFallbackBaseUrl url: URL) -> Self {
        backendFallbackBaseUrl = url
        return self
    }

    @discardableResult
    func with(backendConfigsBaseUrl url: URL) -> Self {
        backendConfigsBaseUrl = url
        return self
    }

    @discardableResult
    func with(proxy host: String, port: Int) -> Self {
        backendProxy = (host: host, port: port)
        return self
    }

    @discardableResult
    func with(loglevel level: BotsiLog.Level) -> Self {
        logLevel = level
        return self
    }

    @discardableResult
    package func with(crosplatformSDKName name: String, version: String) -> Self {
        crossPlatformSDK = (name: name, version: version)
        return self
    }
}
