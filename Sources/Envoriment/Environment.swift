//
//  Environment.swift
//  BotsiSDK
//
//  Created by Andrey Kyashkin on 19.12.2019.
//

import Foundation

struct Environment: Sendable {
    let application: (installationIdentifier: String, version: String?, build: String?)
    let system: (name: String, version: String)
    let sessionIdentifier: String

    @BotsiActor
    private init() async {
        application = (
            installationIdentifier: Environment.Application.installationIdentifier,
            version: Environment.Application.version,
            build: Environment.Application.build
        )
        system = await (
            name: Environment.System.name,
            version: Environment.System.version
        )

        sessionIdentifier = Environment.Application.sessionIdentifier
    }

    @BotsiActor
    static var _instance: Environment?

    @BotsiActor
    static var instance: Environment {
        get async {
            if let instance = _instance { return instance }
            let instance = await Environment()
            _instance = instance
            return instance
        }
    }
}
