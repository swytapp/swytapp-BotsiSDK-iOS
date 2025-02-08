//
//  LifecycleManager.swift
//  BotsiSDK
//
//  Created by Aleksey Goncharov on 27.10.2022.
//

import Foundation
import StoreKit

#if canImport(UIKit)
    import UIKit
#endif

private let log = Log.Category(name: "LifecycleManager")

@BotsiActor
final class LifecycleManager {
    private static let appOpenedSendInterval: TimeInterval = 60.0
    private static let profileUpdateInterval: TimeInterval = 60.0
    private static let profileUpdateShortInterval: TimeInterval = 10.0
    private static let idfaStatusCheckDuration: TimeInterval = 600.0
    private static let idfaStatusCheckInterval: TimeInterval = 5.0

    static let shared = LifecycleManager()

    private var appOpenedSentAt: Date?
    private var newStorefrontCountryAvailable: String?

    func initialize() {
        log.info("LifecycleManager initialize")

        subscribeForLifecycleEvents()
        subscribeForStorefrontUpdate()
        scheduleProfileUpdate()
        scheduleIDFAUpdate()
    }

    private func subscribeForStorefrontUpdate() {
        Task { @BotsiActor [weak self] in
            for await value in BotsiStorefront.updates {
                self?.newStorefrontCountryAvailable = value.countryCode
            }
        }
    }

    // MARK: - Sync Profile Logic

    private var profileIsSyncing = false

    private func scheduleProfileUpdate() {
        log.verbose("LifecycleManager: scheduleProfileUpdate")

        Task { @BotsiActor [weak self] in

            try await Task.sleep(seconds: Self.profileUpdateInterval)

            while true {
                let updateInterval: TimeInterval

                do {
                    try await self?.syncProfile()
                    updateInterval = Self.profileUpdateInterval
                } catch {
                    log.warn("LifecycleManager: syncProfile Error: \(error)")
                    updateInterval = Self.profileUpdateShortInterval
                }

                try await Task.sleep(seconds: updateInterval)
            }
        }
    }

    private func syncProfile() async throws {
        guard !profileIsSyncing else { return }

        defer { profileIsSyncing = false }
        profileIsSyncing = true

        if let storeCountry = newStorefrontCountryAvailable {
            let params = BotsiProfileParameters(storeCountry: storeCountry)

            log.verbose("LifecycleManager: syncProfile with storeCountry = \(storeCountry)")
            try await Botsi.updateProfile(params: params)
            newStorefrontCountryAvailable = nil
        } else {
            log.verbose("LifecycleManager: syncProfile")
            _ = try await Botsi.getProfile()
        }
    }

    // MARK: - App Open Event Logic

    private func subscribeForLifecycleEvents() {
        #if canImport(UIKit)
            Task {
                #if compiler(>=6.0)
                    let didBecomeActiveNotification = UIApplication.didBecomeActiveNotification
                #else
                    let didBecomeActiveNotification = await UIApplication.didBecomeActiveNotification
                #endif
                NotificationCenter.default.addObserver(
                    forName: didBecomeActiveNotification,
                    object: nil,
                    queue: nil,
                    using: handleDidBecomeActiveNotification
                )
            }
        #endif
    }

    @Sendable
    private nonisolated func handleDidBecomeActiveNotification(_: Notification) {
        Task { @BotsiActor in
            log.verbose("handleDidBecomeActiveNotification")
            Botsi.trackSystemEvent(BotsiInternalEventParameters(eventName: "app_become_active"))

            if let appOpenedSentAt, Date().timeIntervalSince(appOpenedSentAt) < Self.appOpenedSendInterval {
                log.verbose("handleDidBecomeActiveNotification SKIP")
                return
            }
            appOpenedSentAt = Date()

            Botsi.trackEvent(.appOpened)
            log.verbose("handleDidBecomeActiveNotification track")

            try? await syncProfile()
        }
    }

    // MARK: - IDFA Update Logic

    private func scheduleIDFAUpdate() {
        Task { @BotsiActor in
            let timerStartedAt = Date()

            while true {
                let now = Date()
                if now.timeIntervalSince1970 - timerStartedAt.timeIntervalSince1970 > Self.idfaStatusCheckDuration {
                    log.verbose("stop IdfaUpdateTimer")
                    return
                }

                let status = await Environment.Device.idfaRetriavalStatus
                log.verbose("idfaUpdateTimer tick, status = \(status)")

                switch status {
                case .allowed:
                    _ = try? await Botsi.getProfile()
                    return
                case .notDetermined:
                    try await Task.sleep(seconds: Self.idfaStatusCheckInterval)
                case .denied, .notAvailable:
                    return
                }
            }
        }
    }
}
