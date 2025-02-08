//
//  ProfileStorage.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

private let log = Log.storage

@BotsiActor
final class ProfileStorage: Sendable {
    private enum Constants {
        static let profileKey = "BotsiSDK_Purchaser_Info"
        static let profileIdKey = "BotsiSDK_Profile_Id"
        static let externalAnalyticsDisabledKey = "BotsiSDK_External_Analytics_Disabled"
        static let syncedTransactionsKey = "BotsiSDK_Synced_Bundle_Receipt"
        static let appleSearchAdsSyncDateKey = "BotsiSDK_Apple_Search_Ads_Sync_Date"
    }

    private static let userDefaults = Storage.userDefaults

    static var profileId: String =
        if let identifier = userDefaults.string(forKey: Constants.profileIdKey) {
            identifier
        } else {
            createProfileId()
        }

    private static func createProfileId() -> String {
        let identifier = UUID().uuidString.lowercased()
        log.debug("create profileId = \(identifier)")
        userDefaults.set(identifier, forKey: Constants.profileIdKey)
        return identifier
    }

    private static var profile: VH<BotsiProfile>? = {
        do {
            return try userDefaults.getJSON(VH<BotsiProfile>.self, forKey: Constants.profileKey)
        } catch {
            log.warn(error.localizedDescription)
            return nil
        }
    }()

    private static var externalAnalyticsDisabled: Bool = userDefaults.bool(forKey: Constants.externalAnalyticsDisabledKey)
    private static var syncedTransactions: Bool = userDefaults.bool(forKey: Constants.syncedTransactionsKey)
    private static var appleSearchAdsSyncDate: Date? = userDefaults.object(forKey: Constants.appleSearchAdsSyncDateKey) as? Date

    var profileId: String { Self.profileId }

    func getProfile() -> VH<BotsiProfile>? { Self.profile }

    func setProfile(_ profile: VH<BotsiProfile>) {
        do {
            try Self.userDefaults.setJSON(profile, forKey: Constants.profileKey)
            Self.profile = profile
            log.debug("saving profile success.")
        } catch {
            log.error("saving profile fail. \(error.localizedDescription)")
        }
    }

    var externalAnalyticsDisabled: Bool { Self.externalAnalyticsDisabled }

    func setExternalAnalyticsDisabled(_ value: Bool) {
        guard Self.externalAnalyticsDisabled != value else { return }
        Self.externalAnalyticsDisabled = value
        Self.userDefaults.set(value, forKey: Constants.externalAnalyticsDisabledKey)
        log.debug("set externalAnalyticsDisabled = \(value).")
    }

    var syncedTransactions: Bool { Self.syncedTransactions }

    func setSyncedTransactions(_ value: Bool) {
        guard Self.syncedTransactions != value else { return }
        Self.syncedTransactions = value
        Self.userDefaults.set(value, forKey: Constants.syncedTransactionsKey)
        log.debug("set syncedTransactions = \(value).")
    }

    var appleSearchAdsSyncDate: Date? { Self.appleSearchAdsSyncDate }

    func setAppleSearchAdsSyncDate() {
        let now = Date()
        Self.appleSearchAdsSyncDate = now
        Self.userDefaults.set(now, forKey: Constants.appleSearchAdsSyncDateKey)
        log.debug("set appleSearchAdsSyncDate = \(now).")
    }

    func clearProfile(newProfileId profileId: String?) {
        Self.clearProfile(newProfileId: profileId)
    }

    @BotsiActor
    static func clearProfile(newProfileId profileId: String?) {
        log.debug("Clear profile")
        if let profileId {
            userDefaults.set(profileId, forKey: Constants.profileIdKey)
            Self.profileId = profileId
            log.debug("set profileId = \(profileId)")
        } else {
            Self.profileId = createProfileId()
        }

        userDefaults.removeObject(forKey: Constants.externalAnalyticsDisabledKey)
        externalAnalyticsDisabled = false
        userDefaults.removeObject(forKey: Constants.syncedTransactionsKey)
        syncedTransactions = false
        userDefaults.removeObject(forKey: Constants.appleSearchAdsSyncDateKey)
        appleSearchAdsSyncDate = nil
        userDefaults.removeObject(forKey: Constants.profileKey)
        profile = nil

        BackendIntroductoryOfferEligibilityStorage.clear()
        PaywallsStorage.clear()
    }
}

extension ProfileStorage {
    func getProfile(profileId: String, withCustomerUserId customerUserId: String?) -> VH<BotsiProfile>? {
        guard let profile = getProfile(),
              profile.value.profileId == profileId
        else { return nil }

        guard let customerUserId else { return profile }
        guard customerUserId == profile.value.customerUserId else { return nil }
        return profile
    }
}
