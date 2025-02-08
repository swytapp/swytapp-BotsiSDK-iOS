//
//  BotsiLog.Handler.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.10.2022.
//

import Foundation

extension Log {
    package typealias Handler = BotsiLog.Handler
}

extension BotsiLog {
    public typealias Handler = @Sendable (Record) -> Void
}
