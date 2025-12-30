//
//  BotsiCustomFont.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 17.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiCustomFont: Decodable, Sendable {
    public let name: String
    
    public struct AppInfo: Decodable, Sendable {
        public let id: Int
    }
    
    private enum CodingKeys: String, CodingKey {
        case name = "aliasIos"
    }
}