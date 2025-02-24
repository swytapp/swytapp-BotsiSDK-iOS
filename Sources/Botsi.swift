//
//  Botsi.swift
//  Botsi
//
//  Created by Vladyslav on 19.02.2025.
//

import Foundation

@BotsiActor
public final class Botsi: Sendable {
    let sdkApiKey: String
    
    package let enableObserver: Bool
    
    // TODO: profileManager
    
    private let storage: BotsiStorageManager = .shared
    
    /// `payment & transaction`
    private let storeKit1Handler: StoreKit1Handler
//    private let storeKit2Handler: StoreKit2Handler?
    
    let botsiClient: BotsiHttpClient
    
    init(from configuration: BotsiConfiguration) async {
        self.sdkApiKey = configuration.sdkApiKey
        self.enableObserver = configuration.enableObserver
        
        self.botsiClient = BotsiHttpClient(with: configuration)
        
//        if #available(iOS 15.0, macOS 12.0, *) {
////            self.storeKit2Handler = StoreKit2Handler(client: botsiClient)
//            self.storeKit1Handler = nil
//        } else {
            let storeKit1Handler = StoreKit1Handler(client: botsiClient)
            self.storeKit1Handler = storeKit1Handler
            await self.storeKit1Handler.startObservingTransactions()
//            self.storeKit2Handler = nil
//        }
        
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

public extension Botsi {
    
    /// `activation method for Botsi SDK`
    nonisolated static func activate(with config: BotsiConfiguration) async throws {
        try await proceedWithActivation(with: config)
    }
    
    private static func proceedWithActivation(with config: BotsiConfiguration) async throws {
        let activationTask = BotsiActivationTask {
            
            // TODO: Extend with:
            // 1. Backend instance later (if more than one is needed)
            // 2. Environment data
            // 3. Refactor configuration
            
            let botsi = await Botsi(from: config)
            setSharedSDK(botsi)
            return botsi
        }
        setActivatingSDK(activationTask)
        _ = await activationTask.value
    }
    
   
    ///
    ///  TODO: TASKS
    ///
    ///   23.02
    ///  1. ✅ createProfile -  Fetch data from backend and write a mapper into BotsiProfile
    ///  2. ✅ getProfile - Receive the BotsiProfile by local user identifier
    ///  3 .✅ Check environment values that are passed
    ///  4. ✅ Prepare /sdk/{apiKey}/products/products-ids/app-store and wrappers for this
    ///  5*. ✅ Create simple Storage Manager for storing BotsiProfile in UserDefaults
    ///
    ///   24.02
    ///  1. ✅ Storekit 1 & 2 make a transaction by received [product_ids] from backend
    ///  2. ✅ Check if we need to receive product from backend or show from StoreKit for now
    ///  3*. Create small SwiftUI application for 3 endpoints
    ///
    ///   25.02-26.02
    ///  1. Create mock validatePurchase request with appropriate parameters
    ///  2. Clone Vizzy app, extend with Botsi
    ///
    ///
    ///
    ///
    
    /// `test create profile method outside`
    typealias ProfileIdentifier = String
    nonisolated static func createProfile(with id: ProfileIdentifier) async throws {
        try await activatedSDK.createUserProfile(with: id)
    }
    
    nonisolated static func getProfile() async throws {
        try await activatedSDK.getUserProfile()
    }
    
    nonisolated static func fetchProductIDs() async throws {
        try await activatedSDK.fetchProductIDs()
    }
    
    // MARK: - Private
    
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
        return try await fetchProductIDsRepository.fetchProductIds(from: "pk_O50YzT5HvlY1fSOP.6en44PYDcnIK2HOzIJi9FUYIE")
    }
    
    // MARK: - Purchase request
    nonisolated static func makePurchase(_ productId: String) async throws {
        try await activatedSDK.makePurchase(from: productId)
    }
    
    func makePurchase(from id: String) async throws {
    
            do {
                if #available(iOS 15.0, *) {
                    await makePurchaseSK2(productID: id)
                } else {
                    let product = try await storeKit1Handler.retrieveSK1Product(with: id)
                    await storeKit1Handler.purchaseSK1(product)
                }
            } catch {
                print("Failed to purchase: \(error.localizedDescription)")
            }
    }
}


// TODO: needs to be reworked, not OK
@available(iOS 15.0, *)
extension Botsi {
    private func makeStoreKit2Handler() -> StoreKit2Handler {
        StoreKit2Handler(client: botsiClient)
    }
        
    fileprivate func makePurchaseSK2(productID: String) async {
        do {
            let sk2Handler = makeStoreKit2Handler()
            let product = try await sk2Handler.retrieveProductAsync(with: productID)
            try await sk2Handler.purchaseSK2(product)
        } catch {
            print("StoreKit2 purchase error:", error)
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
