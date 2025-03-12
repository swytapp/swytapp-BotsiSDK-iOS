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
    
    // TODO: profileManager
    
    private let storage: BotsiStorageManager = .shared
    static let lifecycle = BotsiLifecycle()
    
    /// `payment & transaction`
    private let storeKit1Handler: StoreKit1Handler?
    private let storeKit2Handler: StoreKit2Handler?
    
    let botsiClient: BotsiHttpClient
    
    init(from configuration: BotsiConfiguration) async {
        self.sdkApiKey = configuration.sdkApiKey
        self.enableObserver = configuration.enableObserver
        
        self.botsiClient = BotsiHttpClient(with: configuration, key: configuration.sdkApiKey)
        
        if #available(iOS 15.0, *) {
            self.storeKit2Handler = StoreKit2Handler(client: botsiClient, storage: storage)
            
            self.storeKit1Handler = nil
        } else {
            let storeKit1Handler = StoreKit1Handler(client: botsiClient, storage: storage)
            self.storeKit1Handler = storeKit1Handler
            await self.storeKit1Handler?.startObservingTransactions()
            self.storeKit2Handler = nil
        }
        
        await verifyUser() // CRUD operation for profile
    }
    
    private func verifyUser() async {
        guard let profile = try? await storage.retrieve(BotsiProfile.self, forKey: UserDefaultKeys.User.userProfile) else {
            let uuid = UUID().uuidString
            if let profile = try? await createUserProfile(with: uuid) {
                try? await storage.save(profile, forKey: UserDefaultKeys.User.userProfile)
            }
            return
        }
        print("Fetched user profile with id: \(profile.profileId)")
    }
}
// https://swytapp-test.com.ua/api/sdk/purchases/apple-store/validate
public extension Botsi { // https://swytapp-test.com.ua/sdk/purchases/apple-store/validate
    
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
   
    ///
    ///  TODO: TASKS
    /// ✅
    ///  1. add validate purchase BE request + extend purchasing handlers
    ///  2. restorePurchases
    ///  3. create analytics wrapper
    ///  4. user management system
    ///  5. test in-app purchase and subscription types
    
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
        if let storedProfile = try await storage.retrieve(BotsiProfile.self, forKey: UserDefaultKeys.User.userProfile) {
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
    nonisolated static func makePurchase(_ productId: String) async throws {
        return try await lifecycle.withInitializedSDK { botsi in
            try await botsi.makePurchase(from: productId)
        }
    }
    
    func makePurchase(from id: String) async throws {
        do {
            if #available(iOS 15.0, *) {
                guard let handler = storeKit2Handler else {
                    throw BotsiError.customError("purchaseError", "unable to unwrap storekit 2 handler")
                }
                let products = try await handler.retrieveProductAsync(with: [id])
                guard let product = products.first else {
                    throw BotsiError.customError("productError", "unable to retrieve first product from array")
                }
                try await handler.purchaseSK2(product)
            } else {
                guard let handler = storeKit1Handler else {
                    throw BotsiError.customError("purchaseError", "unable to unwrap storekit 1 handler")
                }
                let product = try await handler.retrieveSK1Product(with: id)
                await storeKit1Handler?.purchaseSK1(product)
            }
        } catch {
            print("Failed to purchase: \(error.localizedDescription)")
            throw BotsiError.transactionFailed
        }
    }
}



/// `This one is useful in testing, while no Products from Backend are received`
/// `We manually fetch the products in order to display them to the user`
@available(iOS 15.0, *)
extension Botsi {
    fileprivate func retrievePurchases(from ids: [String]) async throws -> [Product] {
        do {
            let products = try await storeKit2Handler?.retrieveProductAsync(with: ids)
            return products ?? []
        } catch {
            return []
        }
    }
}


/*
 SDKProject/
 │── SDK/
 │   ├── Core/ // MARK: Holds the foundational services for networking, authentication, caching, and utility functions.
 │   │   ├── Network/
 │   │   │   ├── HTTPManager.swift
 │   │   │   ├── APIClient.swift
 │   │   │   ├── Endpoints.swift
 │   │   ├── Storage/
 │   │   │   ├── CacheManager.swift
 │   │   │   ├── KeychainManager.swift
 │   │   │   ├── UserDefaultsManager.swift
 |   |   |---Purchases/
 |   |   |   |---Storekit1&2.swift
 │   │   ├── Auth/
 │   │   │   ├── AuthManager.swift
 │   │   │   ├── TokenStorage.swift
 │   │   ├── Utils/
 │   │   │   ├── Logger.swift
 │   │   │   ├── Extensions/
 │   │   │   │   ├── URLSession+Extension.swift
 │   │   │   │   ├── Codable+Extension.swift
 │   │   │   │   ├── ErrorHandling.swift
 │   │   ├── DependencyInjection/
 │   │   │   ├── ServiceLocator.swift
 │   ├── Data/ // MARK: Handles fetching, storing, and mapping data between layers.
 │   │   ├── Models/
 │   │   │   ├── DTOs/ // MARK: Defines data transfer objects received from APIs. check android
 │   │   │   │   ├── SomeDTO.swift
 │   │   │   ├── Mappers/ // MARK:  Converts DTOs to domain entities.
 │   │   │   │   ├── SomeEntityMapper.swift
 │   │   ├── Repositories/ // MARK: Interfaces for data fetching. Concrete implementations fetch data from the network or cache.
 │   │   │   ├── SomeRepository.swift
 │   │   │   ├── SomeRepositoryImpl.swift
 │   ├── Domain/ // MARK: Pure business logic and core domain models.
 │   │   ├── Entities/ // MARK:  Represents immutable core models.
 │   │   │   ├── SomeEntity.swift
 │   │   ├── UseCases/
 │   │   │   ├── SomeUseCase.swift // MARK:  Implements business logic and interacts with repositories.
 │   ├── Presentation/ (Optional for UI SDKs)
 │   │   ├── UIComponents/
 │   │   │   ├── CustomButton.swift
 │   │   ├── ViewModels/
 │   │   │   ├── SomeViewModel.swift
 │   ├── Config/
 │   │   ├── SDKConfiguration.swift
 │── ExampleApp/ (For testing the SDK)
 │── Tests/
 │   ├── UnitTests/
 │   │   ├── DataTests/
 │   │   │   ├── SomeRepositoryTests.swift
 │   │   ├── DomainTests/
 │   │   │   ├── SomeUseCaseTests.swift
 │   │   ├── NetworkingTests/
 │   │   │   ├── APIClientTests.swift
 │   ├── IntegrationTests/
 │── SDKProject.podspec (or Package.swift for SPM)
 │── README.md

 */
