//
//  Botsi+Completion.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 19.09.2024
//

import StoreKit

public typealias BotsiResult<Success> = Swift.Result<Success, BotsiError>

public typealias BotsiErrorCompletion = @Sendable (BotsiError?) -> Void
public typealias BotsiResultCompletion<Success> = @Sendable (BotsiResult<Success>) -> Void

public extension Result where Failure == BotsiError {
    var error: BotsiError? {
        switch self {
        case let .failure(error): error
        default: nil
        }
    }
}

package extension BotsiConfiguration {
    @BotsiActor
    static var callbackDispatchQueue: DispatchQueue?
}

public extension Botsi {
    /// Use this method to initialize the Botsi SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter apiKey: You can find it in your app settings in [Botsi Dashboard](https://app.adapty.io/) *App settings* > *General*.
    /// - Parameter observerMode: A boolean value controlling [Observer mode](https://docs.adapty.io/docs/observer-vs-full-mode). Turn it on if you handle purchases and subscription status yourself and use Botsi for sending subscription events and analytics
    /// - Parameter customerUserId: User identifier in your system
    /// - Parameter dispatchQueue: Specify the Dispatch Queue where callbacks will be executed
    /// - Parameter completion: Result callback
    nonisolated static func activate(
        _ apiKey: String,
        observerMode: Bool = false,
        customerUserId: String? = nil,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await activate(apiKey, observerMode: observerMode, customerUserId: customerUserId)
        }
    }

    /// Use this method to initialize the Botsi SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter builder: `BotsiConfiguration.Builder` which allows to configure Botsi SDK
    /// - Parameter completion: Result callback
    nonisolated static func activate(
        with builder: BotsiConfiguration.Builder,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        let configuration = builder.build()
        withCompletion(completion) {
            try await activate(with: configuration)
        }
    }

    /// Use this method to initialize the Botsi SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter configuration: `BotsiConfiguration` which allows to configure Botsi SDK
    /// - Parameter completion: Result callback
    nonisolated static func activate(
        with configuration: BotsiConfiguration,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await activate(with: configuration)
        }
    }

    /// Use this method for identifying user with it's user id in your system.
    ///
    /// If you don't have a user id on SDK configuration, you can set it later at any time with `.identify()` method. The most common cases are after registration/authorization when the user switches from being an anonymous user to an authenticated user.
    ///
    /// - Parameters:
    ///   - customerUserId: User identifier in your system.
    ///   - completion: Result callback.
    nonisolated static func identify(
        _ customerUserId: String,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await identify(customerUserId)
        }
    }

    /// You can logout the user anytime by calling this method.
    /// - Parameter completion: Result callback.
    nonisolated static func logout(
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await logout()
        }
    }

    /// The main function for getting a user profile. Allows you to define the level of access, as well as other parameters.
    ///
    /// The `getProfile` method provides the most up-to-date result as it always tries to query the API. If for some reason (e.g. no internet connection), the Botsi SDK fails to retrieve information from the server, the data from cache will be returned. It is also important to note that the Botsi SDK updates BotsiProfile cache on a regular basis, in order to keep this information as up-to-date as possible.
    ///
    /// - Parameter completion: the result containing a `BotsiProfile` object. This model contains info about access levels, subscriptions, and non-subscription purchases. Generally, you have to check only access level status to determine whether the user has premium access to the app.
    nonisolated static func getProfile(
        _ completion: @escaping BotsiResultCompletion<BotsiProfile>
    ) {
        withCompletion(completion) {
            try await getProfile()
        }
    }

    /// You can set optional attributes such as email, phone number, etc, to the user of your app. You can then use attributes to create user [segments](https://docs.adapty.io/v2.0.0/docs/segments) or just view them in CRM.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/v2.0.0/docs/setting-user-attributes)
    ///
    /// - Parameter params: use `BotsiProfileParameters.Builder` class to build this object.
    nonisolated static func updateProfile(
        params: BotsiProfileParameters,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await updateProfile(params: params)
        }
    }

    /// To set attribution data for the profile, use this method.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/docs/attribution-integration)
    ///
    /// - Parameter attribution: a dictionary containing attribution (conversion) data.
    /// - Parameter source: a source of attribution. The allowed values are: `.appsflyer`, `.adjust`, `.branch`, `.custom`.
    /// - Parameter completion: A result containing an optional error.
    nonisolated static func updateAttribution(
        _ attribution: [AnyHashable: Any],
        source: String,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        let attributionJson: String
        do {
            let data = try JSONSerialization.data(withJSONObject: attribution)
            attributionJson = String(decoding: data, as: UTF8.self)
        } catch {
            completion?(BotsiError.wrongAttributeData(error))
            return
        }

        withCompletion(completion) {
            try await updateAttribution(attributionJson, source: source)
        }
    }

    nonisolated static func setIntegrationIdentifier(
        key: String,
        value: String,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await setIntegrationIdentifier(key: key, value: value)
        }
    }

    /// Botsi allows you remotely configure the products that will be displayed in your app. This way you don't have to hardcode the products and can dynamically change offers or run A/B tests without app releases.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - placementId: The identifier of the desired placement. This is the value you specified when you created the placement in the Botsi Dashboard.
    ///   - locale: The identifier of the paywall [localization](https://docs.adapty.io/docs/paywall#localizations).
    ///             This parameter is expected to be a language code composed of one or more subtags separated by the "-" character. The first subtag is for the language, the second one is for the region (The support for regions will be added later).
    ///             Example: "en" means English, "en-US" represents US English.
    ///             If the parameter is omitted, the paywall will be returned in the default locale.
    ///   - fetchPolicy:by default SDK will try to load data from server and will return cached data in case of failure. Otherwise use `.returnCacheDataElseLoad` to return cached data if it exists.
    ///   - loadTimeout: This value limits the timeout for this method. If the timeout is reached, cached data or local fallback will be returned.
    ///   - completion: A result containing the ``BotsiPaywall`` object. This model contains the list of the products ids, paywall's identifier, custom payload, and several other properties.
    nonisolated static func getPaywall(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: BotsiPaywall.FetchPolicy = .default,
        loadTimeout: TimeInterval? = nil,
        _ completion: @escaping BotsiResultCompletion<BotsiPaywall>
    ) {
        withCompletion(completion) {
            try await getPaywall(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy,
                loadTimeout: loadTimeout
            )
        }
    }

    /// This method enables you to retrieve the paywall from the Default Audience without having to wait for the Botsi SDK to send all the user information required for segmentation to the server.
    ///
    /// - Parameters:
    ///   - placementId: The identifier of the desired placement. This is the value you specified when you created the placement in the Botsi Dashboard.
    ///   - locale: The identifier of the paywall [localization](https://docs.adapty.io/docs/paywall#localizations).
    ///             This parameter is expected to be a language code composed of one or more subtags separated by the "-" character. The first subtag is for the language, the second one is for the region (The support for regions will be added later).
    ///             Example: "en" means English, "en-US" represents US English.
    ///             If the parameter is omitted, the paywall will be returned in the default locale.
    ///   - fetchPolicy:by default SDK will try to load data from server and will return cached data in case of failure. Otherwise use `.returnCacheDataElseLoad` to return cached data if it exists.
    ///   - completion: A result containing the ``BotsiPaywall`` object. This model contains the list of the products ids, paywall's identifier, custom payload, and several other properties.
    nonisolated static func getPaywallForDefaultAudience(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: BotsiPaywall.FetchPolicy = .default,
        _ completion: @escaping BotsiResultCompletion<BotsiPaywall>
    ) {
        withCompletion(completion) {
            try await getPaywallForDefaultAudience(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy
            )
        }
    }

    /// To set fallback paywalls, use this method. You should pass exactly the same payload you're getting from Botsi backend. You can copy it from Botsi Dashboard.
    ///
    /// Botsi allows you to provide fallback paywalls that will be used when a user opens the app for the first time and there's no internet connection. Or in the rare case when Botsi backend is down and there's no cache on the device.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/v2.0.0/docs/ios-displaying-products#fallback-paywalls)
    ///
    /// - Parameters:
    ///   - fileURL:
    ///   - completion: Result callback.
    nonisolated static func setFallbackPaywalls(
        fileURL url: URL,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await setFallbackPaywalls(fileURL: url)
        }
    }

    /// Once you have a ``BotsiPaywall``, fetch corresponding products array using this method.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - paywall: the ``BotsiPaywall`` for which you want to get a products
    ///   - completion: A result containing the ``BotsiPaywallProduct`` objects array. The order will be the same as in the paywalls object. You can present them in your UI
    nonisolated static func getPaywallProducts(
        paywall: BotsiPaywall,
        _ completion: @escaping BotsiResultCompletion<[BotsiPaywallProduct]>
    ) {
        withCompletion(completion) {
            try await getPaywallProducts(paywall: paywall)
        }
    }

    nonisolated static func getPaywallProductsWithoutDeterminingOffer(
        paywall: BotsiPaywall,
        _ completion: @escaping BotsiResultCompletion<[BotsiPaywallProductWithoutDeterminingOffer]>
    ) {
        withCompletion(completion) {
            try await getPaywallProductsWithoutDeterminingOffer(paywall: paywall)
        }
    }

    /// To make the purchase, you have to call this method.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases)
    ///
    /// - Parameters:
    ///   - product: a ``BotsiPaywallProduct`` object retrieved from the paywall.
    ///   - completion: A result containing the ``BotsiPurchaseResult`` object.
    @available(visionOS, unavailable)
    nonisolated static func makePurchase(
        product: BotsiPaywallProduct,
        _ completion: @escaping BotsiResultCompletion<BotsiPurchaseResult>
    ) {
        withCompletion(completion) {
            try await makePurchase(product: product)
        }
    }

    nonisolated static func makePurchase(
        product: BotsiDeferredProduct,
        _ completion: @escaping BotsiResultCompletion<BotsiPurchaseResult>
    ) {
        withCompletion(completion) {
            try await makePurchase(product: product)
        }
    }

    /// You can fetch the StoreKit receipt by calling this method
    ///
    /// If the receipt is not presented on the device, Botsi will try to refresh it by using [SKReceiptRefreshRequest](https://developer.apple.com/documentation/storekit/skreceiptrefreshrequest)
    ///
    /// - Parameters:
    ///   - completion: A result containing the receipt `Data`.
    nonisolated static func getReceipt(
        _ completion: @escaping BotsiResultCompletion<Data>
    ) {
        withCompletion(completion) {
            try await getReceipt()
        }
    }

    /// To restore purchases, you have to call this method.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases#restoring-purchases)
    ///
    /// - Parameter completion: A result containing the ``BotsiProfile`` object. This model contains info about access levels, subscriptions, and non-subscription purchases. Generally, you have to check only access level status to determine whether the user has premium access to the app.
    nonisolated static func restorePurchases(
        _ completion: @escaping BotsiResultCompletion<BotsiProfile>
    ) {
        withCompletion(completion) {
            try await restorePurchases()
        }
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Botsi SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Botsi Dashboard.
    ///
    /// - Parameters:
    ///   - variationId:  A string identifier of variation. You can get it using variationId property of ``BotsiPaywall``.
    ///   - transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 1) [SKPaymentTransaction](https://developer.apple.com/documentation/storekit/skpaymenttransaction).
    /// - Throws: An ``BotsiError`` object
    @available(*, deprecated, renamed: "reportTransaction")
    nonisolated static func setVariationId(
        _ variationId: String,
        forPurchasedTransaction sk1Transaction: SKPaymentTransaction
    ) async throws {
        try await reportTransaction(sk1Transaction, withVariationId: variationId)
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Botsi SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Botsi Dashboard.
    ///
    /// - Parameters:
    ///   - variationId:  A string identifier of variation. You can get it using variationId property of `BotsiPaywall`.
    ///   - transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 2) [Transaction](https://developer.apple.com/documentation/storekit/transaction).
    /// - Throws: An ``BotsiError`` object
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    @available(*, deprecated, renamed: "reportTransaction")
    nonisolated static func setVariationId(
        _ variationId: String,
        forPurchasedTransaction sk2Transaction: Transaction
    ) async throws {
        try await reportTransaction(sk2Transaction, withVariationId: variationId)
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Botsi SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Botsi Dashboard.
    ///
    /// - Parameters:
    ///   - variationId:  A string identifier of variation. You can get it using variationId property of ``BotsiPaywall``.
    ///   - transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 1) [SKPaymentTransaction](https://developer.apple.com/documentation/storekit/skpaymenttransaction).
    ///   - completion: A result containing an optional error.
    @available(*, deprecated, renamed: "reportTransaction")
    nonisolated static func setVariationId(
        _ variationId: String,
        forPurchasedTransaction transaction: SKPaymentTransaction,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await reportTransaction(transaction, withVariationId: variationId)
        }
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Botsi SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Botsi Dashboard.
    ///
    /// - Parameters:
    ///   - variationId:  A string identifier of variation. You can get it using variationId property of `BotsiPaywall`.
    ///   - transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 2) [Transaction](https://developer.apple.com/documentation/storekit/transaction).
    ///   - completion: A result containing an optional error.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    @available(*, deprecated, renamed: "reportTransaction")
    nonisolated static func setVariationId(
        _ variationId: String,
        forPurchasedTransaction transaction: Transaction,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await reportTransaction(transaction, withVariationId: variationId)
        }
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Botsi SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Botsi Dashboard.
    ///
    /// - Parameters:
    ///   - variationId:  A string identifier of variation. You can get it using variationId property of ``BotsiPaywall``.
    ///   - transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 1) [SKPaymentTransaction](https://developer.apple.com/documentation/storekit/skpaymenttransaction).
    ///   - completion: A result containing an optional error.
    nonisolated static func reportTransaction(
        _ transaction: SKPaymentTransaction,
        withVariationId variationId: String? = nil,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await reportTransaction(transaction, withVariationId: variationId)
        }
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Botsi SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Botsi Dashboard.
    ///
    /// - Parameters:
    ///   - variationId:  A string identifier of variation. You can get it using variationId property of `BotsiPaywall`.
    ///   - transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 2) [Transaction](https://developer.apple.com/documentation/storekit/transaction).
    ///   - completion: A result containing an optional error.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    nonisolated static func reportTransaction(
        _ transaction: Transaction,
        withVariationId variationId: String? = nil,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await reportTransaction(transaction, withVariationId: variationId)
        }
    }

    /// Call this method to notify Botsi SDK, that particular paywall was shown to user.
    ///
    /// Botsi helps you to measure the performance of the paywalls. We automatically collect all the metrics related to purchases except for paywall views. This is because only you know when the paywall was shown to a customer.
    /// Whenever you show a paywall to your user, call .logShowPaywall(paywall) to log the event, and it will be accumulated in the paywall metrics.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/v2.0.0/docs/ios-displaying-products#paywall-analytics)
    ///
    /// - Parameters:
    ///   - paywall: A `BotsiPaywall` object.
    ///   - completion: Result callback.
    nonisolated static func logShowPaywall(
        _ paywall: BotsiPaywall,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await logShowPaywall(paywall)
        }
    }

    /// Call this method to keep track of the user's steps while onboarding
    ///
    /// The onboarding stage is a very common situation in modern mobile apps. The quality of its implementation, content, and number of steps can have a rather significant influence on further user behavior, especially on his desire to become a subscriber or simply make some purchases.
    ///
    /// In order for you to be able to analyze user behavior at this critical stage without leaving Botsi, we have implemented the ability to send dedicated events every time a user visits yet another onboarding screen.
    ///
    /// - Parameters:
    ///   - name: Name of your onboarding.
    ///   - screenName: Readable name of a particular screen as part of onboarding.
    ///   - screenOrder: An unsigned integer value representing the order of this screen in your onboarding sequence (it must me greater than 0).
    ///   - completion: Result callback.
    nonisolated static func logShowOnboarding(
        name: String?,
        screenName: String?,
        screenOrder: UInt,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await logShowOnboarding(name: name, screenName: screenName, screenOrder: screenOrder)
        }
    }

    nonisolated static func logShowOnboarding(
        _ params: BotsiOnboardingScreenParameters,
        _ completion: BotsiErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await logShowOnboarding(params)
        }
    }
}

private func withCompletion(
    _ completion: BotsiErrorCompletion? = nil,
    from operation: @escaping @Sendable () async throws -> Void
) {
    guard let completion else {
        Task {
            try? await operation()
        }
        return
    }

    Task {
        do {
            try await operation()
            await (BotsiConfiguration.callbackDispatchQueue ?? .main).async {
                completion(nil)
            }
        } catch {
            await (BotsiConfiguration.callbackDispatchQueue ?? .main).async {
                completion(error.asBotsiError ?? .convertToBotsiErrorFailed(unknownError: error))
            }
        }
    }
}

private func withCompletion<T: Sendable>(
    _ completion: BotsiResultCompletion<T>?,
    from operation: @escaping @Sendable () async throws -> T
) {
    guard let completion else {
        Task {
            _ = try? await operation()
        }
        return
    }

    Task {
        do {
            let result = try await operation()
            await (BotsiConfiguration.callbackDispatchQueue ?? .main).async {
                completion(.success(result))
            }
        } catch {
            await (BotsiConfiguration.callbackDispatchQueue ?? .main).async {
                completion(.failure(error.asBotsiError ?? .convertToBotsiErrorFailed(unknownError: error)))
            }
        }
    }
}
