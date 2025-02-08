//
//  Backend.FallbackExecutor.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 02.10.2024
//

import Foundation

extension Backend {
    struct FallbackExecutor: BackendExecutor {
        let session: HTTPSession
    }

    func createFallbackExecutor() -> FallbackExecutor {
        FallbackExecutor(
            session: HTTPSession(configuration: fallback)
        )
    }
}
