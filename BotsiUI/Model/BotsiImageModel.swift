//
//  BotsiImageModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiImageModel: Decodable, Sendable {
    public let image: String
    public let height: String?
    public let aspect: String
    public let padding: BotsiEdge?
    public let verticalOffset: String?

    private enum CodingKeys: String, CodingKey {
        case image, height, aspect, padding
        case verticalOffset = "vertical_offset"
    }
}