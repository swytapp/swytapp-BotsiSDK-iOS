//
//  FallbackPaywalls.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

private let log = Log.fallbackPaywalls

struct FallbackPaywalls: Sendable {
    private let fileURL: URL
    private let head: Head
    var formatVersion: Int { head.formatVersion }
    var version: Int64 { head.version }

    init(fileURL url: URL) throws {
        guard url.isFileURL else {
            throw BotsiError.isNotFileUrl()
        }
        let decoder = FallbackPaywalls.decoder()
        do {
            head = try decoder.decode(Head.self, from: Data(contentsOf: url))
        } catch let error as BotsiError {
            throw error
        } catch {
            throw BotsiError.decodingFallback(error)
        }
        fileURL = url
    }

    func contains(placementId id: String) -> Bool? {
        head.placementIds?.contains(id)
    }

    /// 2
    func getPaywall(byPlacementId id: String, profileId: String) -> BotsiPaywallChosen? {
        guard contains(placementId: id) ?? true else { return nil }

        let decoder = FallbackPaywalls.decoder(profileId: profileId, placementId: id)
        let chosen: BotsiPaywallChosen?
        do {
            chosen = try decoder.decode(Body.self, from: Data(contentsOf: fileURL)).chosen
        } catch {
            log.error(error.localizedDescription)
            chosen = nil
        }

        return chosen.map {
            var v = $0
            v.value.version = version
            return v
        }
    }
}

extension FallbackPaywalls {
    private enum CodingKeys: String, CodingKey {
        case data
        case meta
        case formatVersion = "version"
        case version = "response_created_at"
        case placementIds = "developer_ids"
    }

    struct Head: Sendable, Decodable {
        let placementIds: Set<String>?
        let version: Int64
        let formatVersion: Int

        init(from decoder: Decoder) throws {
            let container = try decoder
                .container(keyedBy: CodingKeys.self)
                .nestedContainer(keyedBy: CodingKeys.self, forKey: .meta)

            let formatVersion = try container.decode(Int.self, forKey: .formatVersion)

            guard formatVersion == Botsi.fallbackFormatVersion else {
                let error = formatVersion < Botsi.fallbackFormatVersion
                    ? "The fallback paywalls version is not correct. Download a new one from the Botsi Dashboard."
                    : "The fallback paywalls version is not correct. Please update the BotsiSDK."
                log.error(error)

                Task(priority: .high) {
                    await Botsi.trackSystemEvent(BotsiInternalEventParameters(eventName: "fallback_wrong_version", params: [
                        "in_version": formatVersion,
                        "expected_version": Botsi.fallbackFormatVersion,
                    ]))
                }

                throw BotsiError.wrongVersionFallback(error)
            }

            self.formatVersion = formatVersion
            version = try container.decode(Int64.self, forKey: .version)
            placementIds = try container.decodeIfPresent(Set<String>.self, forKey: .placementIds)
        }
    }

    struct Body: Sendable, Decodable {
        let chosen: BotsiPaywallChosen?
        init(from decoder: Decoder) throws {
            let placementId = try AnyCodingKeys(stringValue: decoder.userInfo.placementId)
            let container = try decoder
                .container(keyedBy: CodingKeys.self)
                .nestedContainer(keyedBy: AnyCodingKeys.self, forKey: .data)

            guard container.contains(placementId) else {
                chosen = nil
                return
            }

            if let string = try? container.decode(String.self, forKey: placementId) {
                let decoder = try FallbackPaywalls.decoder(profileId: decoder.userInfo.profileId)
                let data = string.data(using: .utf8) ?? Data()
                chosen = try decoder.decode(BotsiPaywallChosen.self, from: data)
            } else {
                chosen = try container.decodeIfPresent(BotsiPaywallChosen.self, forKey: placementId)
            }
        }
    }
}

extension FallbackPaywalls {
    static let placementIdUserInfoKey = CodingUserInfoKey(rawValue: "botsi_placement_id")!

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        Backend.configure(jsonDecoder: decoder)
        return decoder
    }

    static func decoder(profileId: String) -> JSONDecoder {
        let decoder = decoder()
        decoder.setProfileId(profileId)
        return decoder
    }

    static func decoder(profileId: String, placementId: String) -> JSONDecoder {
        let decoder = decoder(profileId: profileId)
        decoder.userInfo[FallbackPaywalls.placementIdUserInfoKey] = placementId
        return decoder
    }
}

private extension [CodingUserInfoKey: Any] {
    var placementId: String {
        get throws {
            if let value = self[FallbackPaywalls.placementIdUserInfoKey] as? String {
                return value
            }

            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The decoder does not have the \(FallbackPaywalls.placementIdUserInfoKey) parameter"))
        }
    }
}
