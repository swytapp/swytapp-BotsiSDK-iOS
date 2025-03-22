//
//  Botsi.swift
//  Botsi
//
//  Created by Vladyslav on 19.02.2025.
//

import Foundation
import StoreKit

@BotsiActor
public final class Botsi: Sendable {
    let sdkApiKey: String // test `pk_O50YzT5HvlY1fSOP.6en44PYDcnIK2HOzIJi9FUYIE`
    
    package let enableObserver: Bool
        
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
        
        await verifyUser() // CRUD operation for profile
    }
    
    private func verifyUser() async {
        guard let profile = await profileStorage.getProfile() else {
            let uuid = UUID().uuidString
            if let profile = try? await createUserProfile(with: uuid) {
                await profileStorage.setProfile(profile)
            }
            return
        }
        print("Fetched user profile with id: \(profile.profileId)")
    }
}

public extension Botsi {
    
    /// `activation method for Botsi SDK`
    nonisolated static func activate(with config: BotsiConfiguration) async throws {
        try await proceedWithActivation(with: config)
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
        operation: @Sendable @escaping (Botsi) async throws -> T
    ) async throws -> T {
        try await lifecycle.withInitializedSDK(operation: operation)
    }
   

    /// `test create profile method outside`
//    nonisolated static func createProfile(with id: ProfileIdentifier) async throws {
//        let r = try await lifecycle.withInitializedSDK { botsi in
//            try await botsi.createUserProfile(with: id)
//        }
//        
//    }
    
    static var isInitialized: Bool {
        get async {
            await lifecycle.isInitialized
        }
    }
    
    // MARK: - Profile
    
    typealias ProfileIdentifier = String
    nonisolated static func getProfile() async throws -> BotsiProfile {
        return try await lifecycle.withInitializedSDK { botsi in
            try await botsi.getUserProfile()
        }
    }
    
    nonisolated static func fetchProductIDs() async throws -> [String] {
        return try await lifecycle.withInitializedSDK { botsi in
            return try await botsi.fetchProductIDs()
        }
    }
    
    @available(iOS 15.0, *)
    nonisolated static func fetchProducts(from ids: [String]) async throws -> [Product] {
        return try await lifecycle.withInitializedSDK { botsi in
            try await botsi.retrieveProducts(from: ids)
        }
    }
    
    
    // MARK: - User
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

    // MARK: - Product IDs request
    @discardableResult
    private func fetchProductIDs() async throws -> [String] {
        let fetchProductIDsRepository = FetchProductIDsRepository(httpClient: botsiClient)
        return try await fetchProductIDsRepository.fetchProductIds(from: sdkApiKey)
    }
    
    @available(iOS 15.0, *)
    private func retrieveProducts(from ids: [String]) async throws -> [Product] {
        try await retrievePurchases(from: ids)
    }
    
    // MARK: - Purchase request (is triggered from an app)
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
        
        /*
         MARK: Receipt - Bundle.main.appStoreReceiptUrl
         
         StoreKit 1
         - restoreCompletedTransactions()
         - * or SKReceiptRefreshRequest
         
         StoreKit 2
         - AppStore.sync()
         - for await verificationResult in Transaction.currentEntitlements { }
         
         */
    }
    
    nonisolated static func restorePurchases() async throws -> BotsiProfile {
        try await lifecycle.withInitializedSDK { botsi in
            return try await botsi.restorePurchases()
        }
    }
}



public extension Botsi {
    nonisolated static func getPaywall(from placementId: String) async throws -> BotsiPaywall {
        try await lifecycle.withInitializedSDK { botsi in
            return try await botsi.getPaywall(from: placementId)
        }
    }
    
    @discardableResult
    private func getPaywall(from id: String) async throws -> BotsiPaywall {
        guard let profile = await profileStorage.getProfile() else {
            throw BotsiError.userProfileNotFound
        }
        let repository = GetPaywallRepository(httpClient: botsiClient, profileId: profile.profileId)
        return try await repository.getPaywall(id: id)
    }
    
    @available(iOS 15.0, *)
    fileprivate func retrievePurchases(from ids: [String]) async throws -> [Product] {
        do {
            let products = try await storeKit2Handler?.retrieveProductAsync(with: ids)
            return products ?? []
        } catch {
            return []
        }
    }
}
