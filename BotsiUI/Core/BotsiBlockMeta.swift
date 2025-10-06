//
//  BotsiBlockMeta.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 19.06.2025.
//

@available(iOS 15.0, *)
public struct BotsiBlockMeta: Decodable, Sendable {
    public let id: String
    public let blockName: String?
    public let type: BotsiBlockType
    public let icon: String?
    public let parentId: String?
    public let offerType: String?
    public let productId: String?

    private enum CodingKeys: String, CodingKey {
        case blockName = "block_name"
        case id, type, icon, parentId, offerType, productId
    }
}
