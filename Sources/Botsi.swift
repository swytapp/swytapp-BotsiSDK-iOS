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
    
    /// `payment & transaction`
//    let purchasesManager: BotsiPurchasesManagerConformable
    
    let botsiClient: BotsiHttpClient
    
    init(from configuration: BotsiConfiguration) async {
        self.sdkApiKey = configuration.sdkApiKey
        self.enableObserver = configuration.enableObserver
        
        self.botsiClient = BotsiHttpClient(with: configuration)
        
        /// `TODO: we need to update profile`
        ///  Check if it is stored locally or we need to create one from backend
        ///  We need to schedule update: to be decided
        ///  Assign received profile to local cachingmanager
    
        
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
    ///  1. createProfile -  Fetch data from backend and write a mapper into BotsiProfile
    ///  2. getProfile - Receive the BotsiProfile by local user identifier
    ///  3. Check environment values that are passed
    ///  4. Prepare /sdk/{apiKey}/products/products-ids/app-store and wrappers for this
    ///
    ///  5*. Create simple Storage Manager for storing BotsiProfile in UserDefaults
    ///
    ///   24.02
    ///  1. Storekit 1 & 2 make a transaction by received [product_ids] from backend
    ///  2. Check if we need to receive product from backend or show from StoreKit for now
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
        try await activatedSDK.botsiClient.createUserProfile(with: id)
    }
    
    //
    
    private func createProfile(with id: ProfileIdentifier) async throws -> BotsiProfile? {
        try await botsiClient.createUserProfile(with: id)
        return nil
    }
    
//    public nonisolated static func getProfile() async throws -> BotsiProfile {
//        try await withActivatedSDK(methodName: .getProfile) { sdk in
//             /*try await sdk.createdProfileManager.getProfile(*/)
//        }
//    }
    
    
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
