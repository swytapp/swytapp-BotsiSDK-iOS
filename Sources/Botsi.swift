//
//  Botsi.swift
//  Botsi
//
//  Created by Vladyslav on 19.02.2025.
//

import Foundation

@BotsiActor
public final class Botsi: Sendable {
    let sdkApiKey: String // test `pk_O50YzT5HvlY1fSOP.6en44PYDcnIK2HOzIJi9FUYIE`
    
    private let enableObserver: Bool // TODO:
        
    fileprivate let profileStorage: BotsiProfileStorage
    fileprivate let cachedTransactionsStore: BotsiSyncedTransactionStore
    static let lifecycle = BotsiLifecycle()
    
    /// `payment & transaction`
    private let storeKit1Handler: StoreKit1Handler?
    private let storeKit2Handler: StoreKit2Handler?
    
    let botsiClient: BotsiHttpClient
    
    init(from configuration: BotsiConfiguration) async {
        self.sdkApiKey = configuration.sdkApiKey
        self.enableObserver = configuration.enableObserver
        
        self.botsiClient = BotsiHttpClient(with: configuration, key: configuration.sdkApiKey)
        self.profileStorage = await BotsiProfileStorage()
        
        let cachedTransactionsStore = await BotsiSyncedTransactionStore()
        self.cachedTransactionsStore = cachedTransactionsStore
        
        if #available(iOS 15.0, *) {
            self.storeKit2Handler = StoreKit2Handler(
                client: botsiClient,
                storage: profileStorage
            )
            self.storeKit1Handler = nil
        } else {
            let storeKit1Handler = StoreKit1Handler(
                client: botsiClient,
                storage: profileStorage,
                configuration: configuration,
                cachedTransactionsStore: self.cachedTransactionsStore
            )
            self.storeKit1Handler = storeKit1Handler
            await self.storeKit1Handler?.startObservingTransactions()
            self.storeKit2Handler = nil
        }
        
        await verifyUser()
    }
    
    private func verifyUser() async {
        guard let profile = await profileStorage.getProfile() else {
            let uuid = await profileStorage.getNewProfileUUID()
            if let profile = try? await createUserProfile(with: uuid) {
                await profileStorage.setProfile(profile)
                
                // refactor receipt validation logic
                do {
                    try await restorePurchases()
                } catch {
                    print("Unable to refresh receipt on init.")
                }
            }
            return
        }
        print("Fetched user profile with id: \(profile.profileId)")
    }
}

public extension Botsi {
    /// Activates and initializes the Botsi SDK with your configuration.
    ///
    /// This is the entry point for using the Botsi SDK. Call this method before using any other
    /// SDK functionality. The SDK will create and manage user profiles automatically.
    ///
    /// - Parameter config: A `BotsiConfiguration` object containing your SDK API key and observer settings.
    ///
    /// - Throws: An error if the SDK fails to initialize properly.
    ///
    /// - Example:
    ///   ```swift
    ///   do {
    ///       try await Botsi.activate(with: BotsiConfiguration(
    ///           sdkApiKey: "your_api_key",
    ///           enableObserver: true
    ///       ))
    ///       // SDK is now initialized and ready for use
    ///   } catch {
    ///       print("Failed to initialize Botsi SDK: \(error)")
    ///   }
    ///   ```
    
    nonisolated static func activate(_ key: String) async throws {
        let configuration = BotsiConfiguration.build(sdkApiKey: key)
        try await proceedWithActivation(with: configuration)
    }
    
    private static func proceedWithActivation(with config: BotsiConfiguration) async throws {
        try await lifecycle.initializeIfNeeded {
            let botsi = await Botsi(from: config)
            return botsi
        }
    }
    
    static func withInitializedSDK<T: Sendable>(
        identifier: BotsiRequestIdentifier,
        caller: StaticString = #function,
        operation: @BotsiActor @Sendable @escaping (Botsi) async throws -> T
    ) async throws -> T {
        try await lifecycle.withInitializedSDK(operation: operation)
    }
   
    /// Checks if the Botsi SDK has been properly initialized.
    ///
    /// Use this property to verify that the SDK has been successfully initialized
    /// before attempting to use any of its functionality.
    ///
    /// - Returns: `true` if the SDK has been initialized, `false` otherwise.
    
    static var isInitialized: Bool {
        get async {
            await lifecycle.isInitialized
        }
    }
    
    /// Retrieves the current user's profile information.
    ///
    /// This method returns the user profile with information about their purchases and entitlements.
    /// A user profile is automatically created during SDK initialization.
    ///
    /// - Returns: The user's `BotsiProfile` with complete information about purchases and entitlements.
    ///
    /// - Throws: `BotsiError.userProfileNotFound` if no profile has been created for the current user,
    ///           or other errors if the network request fails.
    ///
    /// - Example:
    ///   ```swift
    ///   do {
    ///       let profile = try await Botsi.getProfile()
    ///       print("User profile ID: \(profile.profileId)")
    ///       // Access other profile properties
    ///   } catch {
    ///       print("Failed to get user profile: \(error)")
    ///   }
    ///   ```
    typealias ProfileIdentifier = String
    nonisolated static func getProfile() async throws -> BotsiProfile {
        return try await lifecycle.withInitializedSDK { botsi in
            try await botsi.getUserProfile()
        }
    }
    
    @discardableResult
    private func createUserProfile(with id: ProfileIdentifier) async throws -> BotsiProfile {
        let createProfile = UserProfileRepository(httpClient: botsiClient)
        return try await createProfile.createUserProfile(identifier: id)
    }
    
    @discardableResult
    private func getUserProfile() async throws -> BotsiProfile {
        if let storedProfile = await profileStorage.getProfile() {
            let repository = GetUserProfileRepository(httpClient: botsiClient)
            return try await repository.getUserProfile(identifier: storedProfile.profileId)
        } else {
            throw BotsiError.userProfileNotFound
        }
    }
    
    // MARK: - Product Management

    /// Retrieves the list of product IDs available for the application.
    ///
    /// This method fetches all product identifiers registered with your Botsi account.
    /// These IDs can be used to make purchases or retrieve product details.
    ///
    /// - Returns: An array of product identifiers that can be used for purchases.
    ///
    /// - Throws: An error if the network request fails or if the SDK is not initialized.
    ///
    nonisolated static func fetchProductIDs() async throws -> [String] {
        return try await lifecycle.withInitializedSDK { botsi in
            return try await botsi.fetchProductIDs()
        }
    }
    
    @discardableResult
    private func fetchProductIDs() async throws -> [String] {
        let fetchProductIDsRepository = FetchProductIDsRepository(httpClient: botsiClient)
        return try await fetchProductIDsRepository.fetchProductIds(from: sdkApiKey)
    }

    /// Initiates a purchase for the specified product ID.
    ///
    /// This method handles the entire purchase flow, including presenting the system purchase dialog,
    /// validating the purchase with Apple, and updating the user's profile with the new entitlements.
    ///
    /// - Parameter productId: The identifier of the product to purchase.
    ///
    /// - Returns: Updated user profile after the purchase is complete.
    ///
    /// - Throws: `BotsiError.transactionFailed` if the purchase transaction fails,
    ///           `BotsiError.customError` with details if there are issues with StoreKit handlers,
    ///           or other errors if the product does not exist.
    ///
    /// - Example:
    ///   ```swift
    ///   do {
    ///       let updatedProfile = try await Botsi.makePurchase("premium_subscription")
    ///       // Handle successful purchase
    ///       print("Purchase successful! Updated profile: \(updatedProfile.profileId)")
    ///   } catch {
    ///       print("Purchase failed: \(error)")
    ///   }
    nonisolated static func makePurchase(_ productId: String) async throws -> BotsiProfile {
        return try await lifecycle.withInitializedSDK { botsi in
            try await botsi.makePurchase(from: productId)
        }
    }
    
    func makePurchase(from id: String) async throws -> BotsiProfile {
        do {
            if #available(iOS 15.0, *) {
                guard let handler = storeKit2Handler else {
                    throw BotsiError.customError("purchaseError", "unable to unwrap storekit 2 handler")
                }
                let products = try await handler.retrieveProductAsync(with: [id])
                guard let product = products.first else {
                    throw BotsiError.customError("productError", "unable to retrieve first product from array")
                }
                let profile = try await handler.purchaseSK2(product)
                return profile
            } else {
                guard let handler = storeKit1Handler else {
                    throw BotsiError.customError("purchaseError", "unable to unwrap storekit 1 handler")
                }
                let product = try await handler.retrieveSK1Product(with: id)
                let profile = try await handler.purchaseSK1(product)
                return profile
            }
        } catch {
            print("Failed to purchase: \(error.localizedDescription)")
            throw BotsiError.transactionFailed
        }
    }
    
    /// Restores previously purchased products for the current user.
    ///
    /// Use this method to allow users to restore their previous purchases, typically when they
    /// install your app on a new device or after reinstalling the app. This method will update
    /// the user's profile with all previously purchased entitlements.
    ///
    /// - Returns: Updated user profile with restored purchases.
    ///
    /// - Throws: `BotsiError.restoreFailed` if the restore operation fails,
    ///           or other errors if the network request fails.
    ///
    /// - Example:
    ///   ```swift
    ///   do {
    ///       let restoredProfile = try await Botsi.restorePurchases()
    ///       print("Purchases restored successfully!")
    ///       // Check restored entitlements
    ///   } catch {
    ///       print("Failed to restore purchases: \(error)")
    ///   }
    ///   ```
    nonisolated static func restorePurchases() async throws -> BotsiProfile {
        try await lifecycle.withInitializedSDK { botsi in
            return try await botsi.restorePurchases()
        }
    }
    
    @discardableResult
    private func restorePurchases() async throws -> BotsiProfile {
        do {
            if #available(iOS 15.0, *) {
                guard let handler = storeKit2Handler else {
                    throw BotsiError.customError("restoreError", "unable to unwrap storekit 2 handler")
                }
                let userProfile = try await handler.restorePurchases()
                return userProfile
            } else {
                guard let handler = storeKit1Handler else {
                    throw BotsiError.customError("restoreError", "unable to unwrap storekit 1 handler")
                }
                let userProfile = try await handler.restorePurchases()
                return userProfile
            }
        } catch {
            print("Failed to restore: \(error.localizedDescription)")
            throw BotsiError.restoreFailed
        }
    }
}

public extension Botsi {
    // MARK: - Paywall Management

    /// Retrieves a paywall configuration for the specified placement ID.
    ///
    /// Paywalls contain UI elements and product references for displaying purchase options to users.
    /// Each paywall is configured in the Botsi dashboard and can be retrieved by its placement ID.
    ///
    /// - Parameter placementId: The identifier of the paywall placement.
    ///
    /// - Returns: The paywall configuration with UI elements and product references.
    ///
    /// - Throws: `BotsiError.userProfileNotFound` if no user profile exists,
    ///           or other errors if the network request fails.
    ///
    nonisolated static func getPaywall(from placementId: String) async throws -> BotsiPaywall {
        try await lifecycle.withInitializedSDK { botsi in
            return try await botsi.getPaywall(from: placementId)
        }
    }
    
    private func getPaywall(from id: String) async throws -> BotsiPaywall {
        guard let profile = await profileStorage.getProfile() else {
            throw BotsiError.paywallFetchingFailed
        }
        let repository = GetPaywallRepository(httpClient: botsiClient, profileId: profile.profileId)
        return try await repository.getPaywall(id: id)
    }
    
    /// Retrieves detailed product information for all products in a paywall.
    ///
    /// This method takes a paywall configuration and fetches detailed information for all products
    /// referenced in that paywall, including pricing, descriptions, and other StoreKit information.
    ///
    /// - Parameter paywall: A `BotsiPaywall` object obtained from `getPaywall(from:)`.
    ///
    /// - Returns: Array of product details including pricing, description, and other StoreKit information.
    ///
    /// - Throws: An error if product details cannot be retrieved or if the SDK is not initialized.
    ///
    /// - Example:
    ///   ```swift
    ///   do {
    ///       let paywall = try await Botsi.getPaywall(from: "main_screen_premium")
    ///       let products = try await Botsi.getPaywallProducts(from: paywall)
    ///
    ///       // Display products to the user
    ///       for product in products {
    ///           print("Product: \(product.title)")
    ///           print("Price: \(product.price)")
    ///           // Configure purchase buttons with product information
    ///       }
    ///   } catch {
    ///       print("Failed to get paywall products: \(error)")
    ///   }
    ///   ```
    nonisolated static func getPaywallProducts(from paywall: BotsiPaywall) async throws -> [BotsiProduct] {
        try await lifecycle.withInitializedSDK { botsi in
            return try await botsi.retrieveProductDetails(from: paywall.sourceProducts.map { $0.sourcePoductId })
        }
    }
    
    private func retrieveProductDetails(from identifiers: [String]) async throws -> [BotsiProduct] {
        if #available(iOS 15.0, *) {
            guard let handler = storeKit2Handler else {
                throw BotsiError.customError("retrieveProductDetailsError", "unable to unwrap storekit 2 handler")
            }
            let products = try await handler.retrieveProductAsync(with: identifiers).compactMap { BotsiSK2PaywallProduct(skProduct: $0) }
            return products
        } else {
            guard let handler = storeKit1Handler else {
                throw BotsiError.customError("retrieveProductDetailsError", "unable to unwrap storekit 1 handler")
            }
            let products = try await handler.retrieveSK1Products(from: identifiers).compactMap { BotsiSK1PaywallProduct(skProduct: $0.skProduct )}
            return products
        }
    }
    
    // MARK: - Events
    /// `Analytics`
    private func sendPaywallTrackEvent(event: BotsiLogEvent) async throws {
        let eventsRepository = EventsRepository(httpClient: botsiClient)
        let useCase = BotsiSendEventUseCase(repository: eventsRepository)
        try await useCase.execute(profileId: event.profileId, placementId: event.placementId ?? "", eventType: event.type.rawValue)
    }
    
    private func logPaywallShown(_ paywall: BotsiPaywall) async throws {
        let profileId = await profileStorage.currentProfileId()
        let environment = try await BotsiEnvironment()
        let customContext = BotsiLogEventContext(
            userId: profileId,
            environment: environment
        )
        let loggerWithContext = BotsiEventLoggerFactory.createLoggerWithContext(
            initialContext: customContext,
            sendEventFunction: sendPaywallTrackEvent
        )

        let userActionEvent = BotsiLogEvent(
            profileId: profileId,
            type: .userPaywallShown,
            name: "userPaywallPresentedLog",
            message: "Paywall presented.",
            placementId: "\(paywall.id)"
        )
        await loggerWithContext.logEvent(userActionEvent)
    }
    
    nonisolated static func logPaywallShown(for paywall: BotsiPaywall) async throws {
        try await lifecycle.withInitializedSDK { botsi in
            try await botsi.logPaywallShown(paywall)
        }
    }
}
