//
//  BotsiImageModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public enum BotsiImageAspect: String, CaseIterable, Decodable, Sendable {
    case fill = "Fill"
    case fit = "Fit"
    case stretch = "Stretch"
}

@available(iOS 15.0, *)
public struct BotsiImageModel: Decodable, Sendable, BotsiPaddingProvider {
    public let image: String
    public let height: String?
    public let aspect: BotsiImageAspect
    public let padding: BotsiEdge
    public let verticalOffset: String?

    private enum CodingKeys: String, CodingKey {
        case image, height, aspect, padding
        case verticalOffset = "vertical_offset"
    }
    
    public init(image: String, 
                height: String? = nil,
                aspect: BotsiImageAspect = .fit,
                padding: BotsiEdge = .defaultEdge,
                verticalOffset: String? = nil) {
        self.image = image
        self.height = height
        self.aspect = aspect
        self.padding = padding
        self.verticalOffset = verticalOffset
    }
}
