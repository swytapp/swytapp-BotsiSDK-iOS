//
//  Botsi+SyncIPv4.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 19.12.2023
//

import Foundation

extension BotsiConfiguration {
    @BotsiActor
    static var ipAddressCollectionDisabled = Self.default.ipAddressCollectionDisabled
}

extension Environment.Device {
    @BotsiActor
    static var ipV4Address: String?
}

extension Botsi {
    private static var syncIPv4Started = false

    func startSyncIPv4OnceIfNeeded() {
        guard !BotsiConfiguration.ipAddressCollectionDisabled,
              Environment.Device.ipV4Address == nil,
              !Botsi.syncIPv4Started
        else { return }

        Botsi.syncIPv4Started = true
        Task(priority: .utility) { [weak self] in
            await self?.syncIPv4(after: .now)
        }
    }

    private func syncIPv4(after interval: TaskDuration) async {
        let interval = min(interval, .seconds(10))

        do {
            try await Task.sleep(duration: interval)
            let value = try await cachedIPv4OrFetch()
            _ = try await createdProfileManager.updateProfile(
                params: BotsiProfileParameters(ipV4Address: value)
            )
        } catch {
            Task(priority: .utility) { [weak self] in
                await self?.syncIPv4(after: interval + .seconds(1))
            }
        }
    }

    private func cachedIPv4OrFetch() async throws -> String {
        if let value = Environment.Device.ipV4Address { return value }
        let value = try await Botsi.fetchIPv4()
        Environment.Device.ipV4Address = value
        return value
    }

    private static func fetchIPv4() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in

            URLSession.shared.dataTask(with: URL(string: "https://api.ipify.org?format=json")!) { data, _, error in
                do {
                    if let error { throw error }
                    guard let data else { throw URLError(.cannotDecodeRawData) }
                    struct FetchIPv4Response: Decodable { let ip: String }
                    let response = try JSONDecoder().decode(FetchIPv4Response.self, from: data)
                    continuation.resume(returning: response.ip)
                } catch {
                    continuation.resume(throwing: error)
                }
            }.resume()
        }
    }
}
