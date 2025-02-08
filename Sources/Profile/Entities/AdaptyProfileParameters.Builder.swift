//
//  BotsiProfileParameters.Builder.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

public extension BotsiProfileParameters {
    final class Builder {
        var parameters: BotsiProfileParameters

        public convenience init() {
            self.init(BotsiProfileParameters())
        }

        init(_ values: BotsiProfileParameters) {
            parameters = values
        }

        public func build() -> BotsiProfileParameters { parameters }
    }
}

public extension BotsiProfileParameters.Builder {
    @discardableResult
    func with(firstName value: String?) -> Self {
        parameters.firstName = value
        return self
    }

    @discardableResult
    func with(lastName value: String?) -> Self {
        parameters.lastName = value
        return self
    }

    @discardableResult
    func with(gender value: BotsiProfile.Gender?) -> Self {
        parameters.gender = value
        return self
    }

    @discardableResult
    func with(birthday value: Date?) -> Self {
        guard let value else {
            parameters.birthday = nil
            return self
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        parameters.birthday = formatter.string(from: value)
        return self
    }

    @discardableResult
    func with(email value: String?) -> Self {
        parameters.email = value
        return self
    }

    @discardableResult
    func with(phoneNumber value: String?) -> Self {
        parameters.phoneNumber = value
        return self
    }
}

public extension BotsiProfileParameters.Builder {
    internal func with(customAttributes: BotsiProfile.CustomAttributes?) -> Self {
        parameters.codableCustomAttributes = customAttributes
        return self
    }

    @discardableResult
    func withRemoved(customAttributeForKey key: String) throws -> Self {
        try with(customAttribute: .none, forKey: key)
    }

    @discardableResult
    func with(customAttribute value: String, forKey key: String) throws -> Self {
        try with(customAttribute: .string(value), forKey: key)
    }

    @discardableResult
    func with(customAttribute value: Double, forKey key: String) throws -> Self {
        try with(customAttribute: .double(value), forKey: key)
    }

    internal func with(customAttribute value: BotsiProfile.CustomAttributeValue, forKey key: String) throws -> Self {
        if let error = BotsiProfile.CustomAttributes.validateKey(key) { throw error }
        if let error = value.validate() { throw error }
        var attributes = parameters.codableCustomAttributes ?? BotsiProfile.CustomAttributes()
        attributes.updateValue(value, forKey: key)
        if let error = attributes.validate() { throw error }
        parameters.codableCustomAttributes = attributes
        return self
    }
}

public extension BotsiProfileParameters.Builder {
    @discardableResult
    func with(analyticsDisabled value: Bool?) -> Self {
        parameters.analyticsDisabled = value
        return self
    }
}

#if canImport(AppTrackingTransparency)
    import AppTrackingTransparency

    public extension BotsiProfileParameters.Builder {
        @available(iOS 14, macOS 11.0, visionOS 1.0, *)
        @discardableResult
        func with(appTrackingTransparencyStatus value: ATTrackingManager.AuthorizationStatus?) -> Self {
            guard let value else {
                parameters.appTrackingTransparencyStatus = nil
                return self
            }
            parameters.appTrackingTransparencyStatus = BotsiProfileParameters.AppTrackingTransparencyStatus(from: Int(value.rawValue))
            return self
        }
    }
#endif
