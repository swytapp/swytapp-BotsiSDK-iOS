//
//  BotsiFooterModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiFooterModel: Decodable, Sendable {
    let padding: BotsiEdge
    let spacing: String
    let style: BotsiStyleModel
}
