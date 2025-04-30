//
//  BotsiConfiguration.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import Foundation

public struct BotsiConfiguration: Sendable {
    
    typealias BotsiDelegateQueue = DispatchQueue
    static let `default` = BotsiHttpClient.URLConstants.backendHost

    let sdkApiKey: String
    let customerUserId: String?
    
    let delegateQueue: BotsiDelegateQueue?
    let backend: URL
}

public extension BotsiConfiguration {
    
    protocol BotsiConfigurationAdapterConformable {
        var sdkApiKey: String { get }
        var profileIdentifier: String? { get }
        var customerUserIdentifier: String? { get }
        var backendHost: URL { get }
        
        func buildConfiguration() -> BotsiConfiguration
    }
    
    static func build(sdkApiKey: String) -> Self {
        return BotsiConfigurationFactory
            .createAdapter(with: sdkApiKey)
            .buildConfiguration()
    }
    
    @discardableResult
    func set(profileIdentifier: String) -> Self {
        return BotsiConfigurationFactory
            .createAdapter(with: sdkApiKey)
            .set(profileIdentifier: profileIdentifier)
            .buildConfiguration()
    }
    
    @discardableResult func set(customerUserIdentifier: String) -> Self {
        return BotsiConfigurationFactory
            .createAdapter(with: sdkApiKey)
            .set(customerIdentifier: customerUserIdentifier)
            .buildConfiguration()
            
    }
}

public extension BotsiConfiguration {
    fileprivate struct BotsiConfigurationFactory {
        public static func createAdapter(with sdkApiKey: String, customerUserIdentifier: String? = nil) -> BotsiConfigurationAdapter {
            return BotsiConfigurationAdapter(
                sdkApiKey: sdkApiKey,
                backendHost: BotsiHttpClient.URLConstants.backendHost
            )
        }
    }
    
    struct BotsiConfigurationAdapter: BotsiConfigurationAdapterConformable {
        public private(set) var profileIdentifier: String?
        public private(set) var sdkApiKey: String
        public private(set) var customerUserIdentifier: String?
        public private(set) var backendHost: URL
        
        init(
            sdkApiKey: String,
            profileIdentifier: String? = nil,
            customerUserIdentifier: String? = nil,
            backendHost: URL
        ) {
            self.sdkApiKey = sdkApiKey
            self.backendHost = backendHost
            self.customerUserIdentifier = customerUserIdentifier
            self.profileIdentifier = profileIdentifier
        }
        
        public func buildConfiguration() -> BotsiConfiguration {
            return .init(
                sdkApiKey: self.sdkApiKey,
                customerUserId: nil,
                delegateQueue: nil,
                backend: self.backendHost
            )
        }
        
        public func set(
            profileIdentifier: String? = nil,
            customerIdentifier: String? = nil
        ) -> Self {
            return .init(
                sdkApiKey: sdkApiKey,
                profileIdentifier: profileIdentifier,
                customerUserIdentifier: customerIdentifier,
                backendHost: backendHost
            )
        }
    }
}
