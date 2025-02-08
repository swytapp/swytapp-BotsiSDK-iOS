//
//  Botsi+Profile.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 22.09.2024
//

import Foundation

extension Botsi {
    /// The main function for getting a user profile. Allows you to define the level of access, as well as other parameters.
    ///
    /// The `getProfile` method provides the most up-to-date result as it always tries to query the API. If for some reason (e.g. no internet connection), the Botsi SDK fails to retrieve information from the server, the data from cache will be returned. It is also important to note that the Botsi SDK updates BotsiProfile cache on a regular basis, in order to keep this information as up-to-date as possible.
    public nonisolated static func getProfile() async throws -> BotsiProfile {
        try await withActivatedSDK(methodName: .getProfile) { sdk in
             try await sdk.createdProfileManager.getProfile()
        }
    }

    /// You can set optional attributes such as email, phone number, etc, to the user of your app. You can then use attributes to create user [segments](https://docs.adapty.io/v2.0.0/docs/segments) or just view them in CRM.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/v2.0.0/docs/setting-user-attributes)
    ///
    /// - Parameter params: use `BotsiProfileParameters.Builder` class to build this object.
    public nonisolated static func updateProfile(params: BotsiProfileParameters) async throws {
        try await withActivatedSDK(methodName: .updateProfile) { sdk in
            _ = try await sdk.createdProfileManager.updateProfile(params: params)
        }
    }
}
