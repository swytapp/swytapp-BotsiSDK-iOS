//
//  BotsiProfileStorage.swift
//  Botsi
//
//  Created by Vladyslav on 12.03.2025.
//

import Foundation

public actor BotsiProfileStorage: Sendable {
    private let storageManager: BotsiStorageManager = BotsiStorageManager()

    // MARK: - Properties Stored in UserDefaults
    
    private var profileId: String
    private var profile: BotsiProfile?
    
    private var externalAnalyticsDisabled: Bool = false
    private var syncedTransactions: Bool = false

    // MARK: - Initialization
    
    /// `Load all relevant state from storage`
    init() async {
        do {
            guard let storedProfile = try await storageManager.retrieve(BotsiProfile.self, forKey: UserDefaultKeys.User.userProfile) else {
                throw BotsiError.customError("Storage manager", "Unable to retrieve user profile")
            }
            self.profile = storedProfile
            self.profileId = storedProfile.profileId
        } catch {
            self.profileId = BotsiProfileStorage.generateProfileId()
            self.profile = nil
        }
        
        
    }
    
    // MARK: - Public Accessors
    func currentProfileId() -> String {
        return profileId
    }
    
    func isExternalAnalyticsDisabled() -> Bool {
        return externalAnalyticsDisabled
    }
    
    func hasSyncedTransactions() -> Bool {
        return syncedTransactions
    }
    
    func getProfile() -> BotsiProfile? {
        return profile
    }
    
    func getNewProfileUUID() -> String {
        let uuid = BotsiProfileStorage.generateProfileId()
        profileId = uuid
        return uuid
    }

    func getProfile(
        profileId: String,
        withCustomerUserId customerUserId: String?
    ) -> BotsiProfile? {
        guard let savedProfile = profile,
              savedProfile.profileId == profileId
        else {
            return nil
        }
        
        // If no customerUserId is provided, any profile is valid
        guard let customerUserId else {
            return savedProfile
        }
        
        // Otherwise, check that it matches
        return (customerUserId == savedProfile.customerUserId)
            ? savedProfile
            : nil
    }
    
    // MARK: - Mutators
    
    func setProfile(_ newProfile: BotsiProfile) async {
        do {
            try await storageManager.save(newProfile, forKey: UserDefaultKeys.User.userProfile)
            profile = newProfile
            BotsiLog.debug("Profile saved successfully.")
        } catch {
            BotsiLog.error("Failed to save profile. \(error.localizedDescription)")
        }
    }
    
    func setSyncedTransactions(_ value: Bool) async throws {
        guard syncedTransactions != value else { return }
        syncedTransactions = value
        
        try await storageManager.save(value, forKey: UserDefaultKeys.User.syncedTransactions)
        
        BotsiLog.debug("Set syncedTransactions = \(value)")
    }
    
    func clearProfile() async {
        BotsiLog.debug("Clearing profile...")
        
        await storageManager.delete(forKey: UserDefaultKeys.User.userProfile)
        await storageManager.delete(forKey: UserDefaultKeys.User.syncedTransactions)
       
        BackendIntroductoryOfferEligibilityStorage.clear()
        PaywallsStorage.clear()
        
        BotsiLog.debug("Profile cleared.")
    }
    
    // MARK: - Private Helpers
    
    private static func generateProfileId() -> String {
        let newId = UUID().uuidString.lowercased()
        BotsiLog.debug("create profileId = \(newId)")
        return newId
    }
}

// TODO: - Other Storage settings

enum BackendIntroductoryOfferEligibilityStorage {
    static func clear() {
        BotsiLog.debug("Cleared BackendIntroductoryOfferEligibilityStorage.")
    }
}

enum PaywallsStorage {
    static func clear() {
        BotsiLog.debug("Cleared PaywallsStorage.")
    }
}
