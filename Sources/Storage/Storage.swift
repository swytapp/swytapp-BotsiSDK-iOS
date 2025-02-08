//
//  Storage.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 15.10.2024
//

import Foundation

private let log = Log.storage

final class Storage {
    private enum Constants {
        static let appKeyHash = "BotsiSDK_Application_Key_Hash"
        static let appInstallationIdentifier = "BotsiSDK_Application_Install_Identifier"
    }

    static var userDefaults: UserDefaults { .standard }

    @BotsiActor
    fileprivate static var appInstallationIdentifier: String =
        if let identifier = userDefaults.string(forKey: Constants.appInstallationIdentifier) {
            identifier
        } else {
            createAppInstallationIdentifier()
        }

    @BotsiActor
    private static func createAppInstallationIdentifier() -> String {
        let identifier = UUID().uuidString.lowercased()
        log.debug("appInstallationIdentifier = \(identifier)")
        userDefaults.set(identifier, forKey: Constants.appInstallationIdentifier)
        return identifier
    }

    @discardableResult
    @BotsiActor
    static func clearAllDataIfDifferent(apiKey: String) async -> Bool {
        let hash = apiKey.sha256()

        guard let value = userDefaults.string(forKey: Constants.appKeyHash) else {
            userDefaults.set(hash, forKey: Constants.appKeyHash)
            return false
        }

        if value == hash { return false }

        ProfileStorage.clearProfile(newProfileId: nil)
        await EventsStorage.clearAll()
        await ProductVendorIdsStorage.clear()
        await VariationIdStorage.clear()
        userDefaults.set(hash, forKey: Constants.appKeyHash)
        log.verbose("changing apiKeyHash = \(hash).")
        return true
    }
}

extension Environment.Application {
    @BotsiActor
    static let installationIdentifier = Storage.appInstallationIdentifier
}
