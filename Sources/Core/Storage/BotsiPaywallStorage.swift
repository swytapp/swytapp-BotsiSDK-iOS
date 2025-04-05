//
//  BotsiPaywallMappingStorage.swift
//  Botsi
//
//  Created by Vladyslav on 05.04.2025.
//

import Foundation


@BotsiPaywallMappingStorage.InternalActor
final class BotsiPaywallMappingStorage: Sendable {
    @globalActor
    actor InternalActor {
        package static let shared = InternalActor()
    }
    
    enum Constants {
        static let paywallIds = "current_botsi_paywall_ids"
        static let cachedPaywallIds = "cached_botsi_paywall_ids"
        static let paywalls = "current_botsi_paywalls"
    }
    
    typealias PaywallID = Int
    typealias PaywallParameters = [String: PaywallID]
    
    private static let storage = UserDefaults.standard

    private static var paywallIds: PaywallParameters =
        storage.dictionary(forKey: Constants.paywallIds) as? PaywallParameters ?? [:]
    
    private static var cachedPaywallIds: [String: PaywallID] =
        storage.dictionary(forKey: Constants.cachedPaywallIds) as? PaywallParameters ?? paywallIds

    fileprivate var paywallIds: PaywallParameters { Self.paywallIds }
    fileprivate var cachedPaywallIds: PaywallParameters { Self.cachedPaywallIds }
    
    private let storageManager: BotsiStorageManager = BotsiStorageManager()

    @discardableResult
    fileprivate func setPersistentPaywallId(_ paywallId: PaywallID, for productId: String) -> Bool {
        guard paywallId != Self.cachedPaywallIds.updateValue(paywallId, forKey: productId) else { return false }
        Self.storage.set(Self.cachedPaywallIds, forKey: Constants.cachedPaywallIds)
        return true
    }

    @discardableResult
    fileprivate func setPaywallId(_ paywallId: PaywallID, for productId: String) -> Bool {
        guard paywallId != Self.paywallIds.updateValue(paywallId, forKey: productId) else { return false }
        Self.storage.set(Self.paywallIds, forKey: Constants.paywallIds)
        BotsiLog.debug("Saving paywallId \(paywallId) for purchased product \(productId)")
        return true
    }

    fileprivate func removePaywallId(for productId: String) -> Bool {
        guard Self.paywallIds.removeValue(forKey: productId) != nil else { return false }
        Self.storage.set(Self.paywallIds, forKey: Constants.paywallIds)
        BotsiLog.debug("Removing paywallId for purchased product \(productId)")
        return true
    }

    static func clear() {
        paywallIds = [:]
        cachedPaywallIds = [:]
        storage.removeObject(forKey: Constants.paywallIds)
        storage.removeObject(forKey: Constants.cachedPaywallIds)
    }
    
    static func getProductIds(for paywallId: PaywallID) -> [String] {
        return paywallIds.filter { $0.value == paywallId }.map { $0.key }
    }
}

extension BotsiPaywallMappingStorage {
    nonisolated func getPaywallIds(for productId: String) async -> (current: PaywallID?, cached: PaywallID?) {
        await (paywallIds[productId], cachedPaywallIds[productId])
    }

    nonisolated func setPaywallIds(_ paywallId: PaywallID, for productId: String) async {
        Task {
            await setPaywallId(paywallId, for: productId)
            await setPersistentPaywallId(paywallId, for: productId)
        }
    }

    nonisolated func setPaywall(_ paywallId: PaywallID, for productId: String) async {
        await setPaywallIds(paywallId, for: productId)
    }

    nonisolated func setPaywall(_ paywallId: PaywallID, for productIds: [String]) async {
        guard !productIds.isEmpty else { return }
        
        for productId in productIds {
            await setPaywallIds(paywallId, for: productId)
        }
    }

    nonisolated func removePaywallMapping(for productId: String) async {
        Task {
            guard await removePaywallId(for: productId) else { return }
        }
    }
    
    nonisolated func hasPaywallMapping(productId: String) async -> Bool {
        let (current, _) = await getPaywallIds(for: productId)
        return current != nil
    }
}
