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
    
    /// `payment & transaction`
//    let purchasesManager: BotsiPurchasesManagerConformable
    
    let botsiClient: BotsiHttpClient
    
    init(from configuration: BotsiConfiguration) async {
        self.sdkApiKey = configuration.sdkApiKey
        self.enableObserver = configuration.enableObserver
        
        self.botsiClient = BotsiHttpClient(with: configuration)
    }
}

public extension Botsi {
    
    /// `activation method for Botsi SDK`
    nonisolated static func activate(with config: BotsiConfiguration) async throws {
        try await proceedWithActivation(with: config)
    }
    
    private static func proceedWithActivation(with config: BotsiConfiguration) async throws {
        let activationTask = BotsiActivationTask {
            let botsi = await Botsi(from: config)
            setSharedSDK(botsi)
            return botsi
        }
        setActivatingSDK(activationTask)
        _ = await activationTask.value
    }
    
    /// `test create profile method outside`
    nonisolated static func createProfile() async throws {
        try await activatedSDK.botsiClient.createUserProfile()
    }
}


enum BotsiOperationIdentifier: String {
    case activate
    case authenticate
    case logout

    case getProfile
    case updateProfile
   
    case makePurchase
    case restorePurchases
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
