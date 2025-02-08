//
//  Backend+Codable.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

extension Backend {
    fileprivate static let isBackendCodableUserInfoKey = CodingUserInfoKey(rawValue: "botsi_backend")!
    fileprivate static let profileIdUserInfoKey = CodingUserInfoKey(rawValue: "botsi_profile_id")!

    static func configure(jsonDecoder: JSONDecoder) {
        jsonDecoder.dateDecodingStrategy = .formatted(Backend.dateFormatter)
        jsonDecoder.dataDecodingStrategy = .base64
        jsonDecoder.setIsBackend()
    }

    static func configure(jsonEncoder: JSONEncoder) {
        jsonEncoder.dateEncodingStrategy = .formatted(Backend.inUTCDateFormatter)
        jsonEncoder.dataEncodingStrategy = .base64
        jsonEncoder.setIsBackend()
    }

    static let inUTCDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
}

extension CodingUserInfoСontainer {
    fileprivate func setIsBackend() {
        userInfo[Backend.isBackendCodableUserInfoKey] = true
    }

    func setProfileId(_ value: String) {
        userInfo[Backend.profileIdUserInfoKey] = value
    }
}

extension [CodingUserInfoKey: Any] {
    var isBackend: Bool {
        self[Backend.isBackendCodableUserInfoKey] as? Bool ?? false
    }

    var profileId: String {
        get throws {
            if let value = self[Backend.profileIdUserInfoKey] as? String {
                return value
            }

            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The decoder does not have the \(Backend.profileIdUserInfoKey) parameter"))
        }
    }
}

extension Backend {
    enum CodingKeys: String, CodingKey {
        case data
        case type
        case id
        case attributes
        case meta
    }
}

extension Encoder {
    func backendContainer<Key: CodingKey>(type: String, keyedBy: Key.Type) throws -> KeyedEncodingContainer<Key> {
        var container = container(keyedBy: Backend.CodingKeys.self)
        var dataObject = container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataObject.encode(type, forKey: .type)
        return dataObject.nestedContainer(keyedBy: Key.self, forKey: .attributes)
    }
}

extension Backend.Response {
    struct ValueOfData<Value>: Sendable, Decodable where Value: Decodable, Value: Sendable {
        let value: Value

        init(_ value: Value) {
            self.value = value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Backend.CodingKeys.self)
            value = try container.decode(Value.self, forKey: .data)
        }
    }

    struct ValueOfMeta<Meta>: Sendable, Decodable where Meta: Decodable, Meta: Sendable {
        let meta: Meta

        init(_ meta: Meta) {
            self.meta = meta
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Backend.CodingKeys.self)
            meta = try container.decode(Meta.self, forKey: .meta)
        }
    }
}
