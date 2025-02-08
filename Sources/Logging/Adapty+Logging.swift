//
//  Botsi+Logging.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 25.09.2024
//

import Foundation

extension Botsi {
    /// Set to the most appropriate level of logging
    public nonisolated static var logLevel: BotsiLog.Level {
        get { Log.level }
        set {
            Task {
                await Log.set(level: newValue)
            }
        }
    }

    /// Register the log handler to define the desired behavior, such as writing logs to files or sending them to your server.
    /// This will not override the default behavior but will add a new one.
    ///
    /// - Parameter handler: The function will be called for each message with the appropriate `logLevel`
    public nonisolated static func setLogHandler(_ handler: BotsiLog.Handler?) { 
        Task {
            await Log.set(handler: handler)
        }
    }
}
