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
    
    private let botsiBackend: BotsiBackend
    
    init(from configuration: BotsiConfiguration) async {
        self.sdkApiKey = configuration.sdkApiKey
        self.enableObserver = configuration.enableObserver
        
        self.botsiBackend = BotsiBackend()
        
        
//        self.purchasesManager
    }
}

public extension Botsi {
    
    /// `activation method for Botsi SDK`
    nonisolated static func activate(with adapter: BotsiConfiguration.BotsiConfigurationAdapter) async throws {
        try await activate(with: adapter.buildConfiguration())
    }
    
    private static func activate(with configuration: BotsiConfiguration) async throws {
        let activationTask = BotsiActivationTask {
            let botsi = await Botsi(from: configuration)
            setSharedSDK(botsi)
            return botsi
        }
        setActivatingSDK(activationTask)
        _ = await activationTask.value
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

// MARK: - Backend

public struct BotsiBackend : Sendable{
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()
    
    
    struct URLConstants {
        static let backendHost: URL = URL(string: "https://api.adapty.io/api/v1")!
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
