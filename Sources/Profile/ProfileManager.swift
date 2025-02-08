//
//  ProfileManager.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import Foundation

@BotsiActor
final class ProfileManager: Sendable {
    nonisolated let profileId: String
    var profile: VH<BotsiProfile>
    var onceSentEnvironment: SendedEnvironment

    let storage: ProfileStorage
    let paywallsStorage = PaywallsStorage()
    let backendIntroductoryOfferEligibilityStorage = BackendIntroductoryOfferEligibilityStorage()

    @BotsiActor
    init(
        storage: ProfileStorage,
        profile: VH<BotsiProfile>,
        sendedEnvironment: SendedEnvironment
    ) {
        let profileId = profile.value.profileId
        self.profileId = profileId
        self.profile = profile
        self.onceSentEnvironment = sendedEnvironment
        self.storage = storage

        Task { [weak self] in
            Botsi.optionalSDK?.updateASATokenIfNeed(for: profile)

            if sendedEnvironment == .dont {
                _ = await self?.getProfile()
            } else {
                self?.syncTransactionsIfNeed(for: profileId)
            }

            Botsi.callDelegate { $0.didLoadLatestProfile(profile.value) }
        }
    }
}

extension ProfileManager {
    nonisolated func syncTransactionsIfNeed(for profileId: String) { // TODO: extruct this code from ProfileManager
        Task { @BotsiActor [weak self] in
            guard let sdk = Botsi.optionalSDK,
                  let self,
                  !self.storage.syncedTransactions
            else { return }

            try? await sdk.syncTransactions(for: profileId)
        }
    }

    func updateProfile(params: BotsiProfileParameters) async throws -> BotsiProfile {
        try await syncProfile(params: params)
    }

    func getProfile() async -> BotsiProfile {
        syncTransactionsIfNeed(for: profileId)
        return await (try? syncProfile(params: nil)) ?? profile.value
    }

    private func syncProfile(params: BotsiProfileParameters?) async throws -> BotsiProfile {
        if let analyticsDisabled = params?.analyticsDisabled {
            storage.setExternalAnalyticsDisabled(analyticsDisabled)
        }

        let meta = await onceSentEnvironment.getValueIfNeedSend(
            analyticsDisabled: (params?.analyticsDisabled ?? false) || storage.externalAnalyticsDisabled
        )

        return try await Botsi.activatedSDK.syncProfile(
            profile: profile,
            params: params,
            environmentMeta: meta
        )
    }

    func saveResponse(_ newProfile: VH<BotsiProfile>?) {
        guard let newProfile,
              profile.value.profileId == newProfile.value.profileId,
              !profile.hash.nonOptionalIsEqual(newProfile.hash),
              profile.value.version <= newProfile.value.version
        else { return }

        profile = newProfile
        storage.setProfile(newProfile)

        Botsi.callDelegate { $0.didLoadLatestProfile(newProfile.value) }
    }
}

extension Botsi {
    func syncTransactions(for profileId: String) async throws {
        let response = try await transactionManager.syncTransactions(for: profileId)

        if profileStorage.profileId == profileId {
            profileStorage.setSyncedTransactions(true)
        }
        profileManager?.saveResponse(response)
    }

    func saveResponse(_ newProfile: VH<BotsiProfile>, syncedTrunsaction: Bool = false) {
        if syncedTrunsaction, profileStorage.profileId == newProfile.value.profileId {
            profileStorage.setSyncedTransactions(true)
        }
        profileManager?.saveResponse(newProfile)
    }
}

private extension Botsi {
    func syncProfile(profile old: VH<BotsiProfile>, params: BotsiProfileParameters?, environmentMeta meta: Environment.Meta?) async throws -> BotsiProfile {
        do {
            let response = try await httpSession.syncProfile(
                profileId: old.value.profileId,
                parameters: params,
                environmentMeta: meta,
                responseHash: old.hash
            )

            if let manager = try profileManager(with: old.value.profileId) {
                if let meta {
                    manager.onceSentEnvironment = meta.sendedEnvironment
                }
                manager.saveResponse(response.flatValue())
            }
            return response.value ?? old.value
        } catch {
            throw error.asBotsiError ?? .syncProfileFailed(unknownError: error)
        }
    }
}
