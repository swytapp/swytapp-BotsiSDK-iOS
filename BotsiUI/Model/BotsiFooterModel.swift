//
//  BotsiFooterModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiFooterModel: Decodable, Sendable {
    public let children: [BotsiBlockRawModel]?
}

@available(iOS 15.0, *)
public struct BotsiBlockRawModel: Decodable, Identifiable, Sendable {
    public let id: String
    public let type: BotsiBlockType
    public let content: BotsiBlockContentValue?
    public let meta: BotsiBlockMeta?
    public let children: [BotsiBlockRawModel]?
}
