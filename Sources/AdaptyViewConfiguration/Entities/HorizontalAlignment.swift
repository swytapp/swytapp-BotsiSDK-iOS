//
//  HorizontalAlignment.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension BotsiViewConfiguration {
    package enum HorizontalAlignment: String {
        case leading
        case trailing
        case left
        case center
        case right
        case justified
    }
}

extension BotsiViewConfiguration.HorizontalAlignment: Decodable {}
