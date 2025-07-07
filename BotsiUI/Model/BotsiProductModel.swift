//
//  BotsiProductModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiProductsModel: Codable, Sendable {
    public let items: [BotsiProductItemModel]?
}

@available(iOS 15.0, *)
public struct BotsiProductItemModel: Codable, Sendable {
    public let productId: String?
    public let style: ProductStyle?

    public struct ProductStyle: Codable, Sendable {
        public let layout: String
        public let highlight: Bool
    }
}
