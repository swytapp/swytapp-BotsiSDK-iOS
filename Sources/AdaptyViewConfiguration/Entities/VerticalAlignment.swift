//
//  VerticalAlignment.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension BotsiViewConfiguration {
    package enum VerticalAlignment: String {
        case top
        case center
        case bottom
        case justified
    }
}

extension BotsiViewConfiguration.VerticalAlignment: Decodable {}
