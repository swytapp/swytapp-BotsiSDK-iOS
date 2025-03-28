//
//  BotsiConfiguration.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import Foundation

public struct BotsiConfiguration: Sendable {
    
    typealias BotsiDelegateQueue = DispatchQueue
    static let `default` = (
        enableObserver: false,
        backend: BotsiHttpClient.URLConstants.backendHost
    )

    let sdkApiKey: String
    let customerUserId: String?
    
    let enableObserver: Bool
    let delegateQueue: BotsiDelegateQueue?
    let backend: URL
}

public extension BotsiConfiguration {
    
    protocol BotsiConfigurationAdapterConformable {
        var sdkApiKey: String { get }
        var profileIdentifier: String? { get }
        var enableObserver: Bool { get }
        var backendHost: URL { get }
        
        func buildConfiguration() -> BotsiConfiguration
    }
    
    static func build(sdkApiKey: String, enableObserver: Bool = false) -> Self {
        return BotsiConfigurationFactory.createAdapter(with: sdkApiKey, enableObserver: enableObserver).buildConfiguration()
    }
    
    @discardableResult
    func set(profileIdentifier: String) -> Self {
        return BotsiConfigurationFactory.createAdapter(with: sdkApiKey, enableObserver: enableObserver)
            .set(profileIdentifier: profileIdentifier)
            .buildConfiguration()
    }
}

public extension BotsiConfiguration {
    fileprivate struct BotsiConfigurationFactory {
        public static func createAdapter(with sdkApiKey: String, enableObserver: Bool) -> BotsiConfigurationAdapter {
            return BotsiConfigurationAdapter(sdkApiKey: sdkApiKey, enableObserver: enableObserver, backendHost: BotsiHttpClient.URLConstants.backendHost)
        }
    }
    
    struct BotsiConfigurationAdapter: BotsiConfigurationAdapterConformable {
        public private(set) var profileIdentifier: String?
        public private(set) var sdkApiKey: String
        public private(set) var enableObserver: Bool
        public private(set) var backendHost: URL
        
        init(sdkApiKey: String, profileIdentifier: String? = nil, enableObserver: Bool = false, backendHost: URL) {
            self.sdkApiKey = sdkApiKey
            self.enableObserver = enableObserver
            self.backendHost = backendHost
            self.profileIdentifier = profileIdentifier
        }
        
        public func buildConfiguration() -> BotsiConfiguration {
            return .init(sdkApiKey: self.sdkApiKey, customerUserId: nil, enableObserver: self.enableObserver, delegateQueue: nil, backend: self.backendHost)
        }
        
        public func set(profileIdentifier: String) -> Self {
            return .init(sdkApiKey: sdkApiKey, profileIdentifier: profileIdentifier, enableObserver: enableObserver, backendHost: backendHost)
        }
    }
}
