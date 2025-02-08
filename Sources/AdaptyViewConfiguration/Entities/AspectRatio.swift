//
//  AspectRatio.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension BotsiViewConfiguration {
    package enum AspectRatio: String {
        case fit
        case fill
        case stretch
    }
}

extension BotsiViewConfiguration.AspectRatio: Decodable {}
