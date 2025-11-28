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
    
    public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            image = try container.decode(String.self, forKey: .image)
            height = try container.decodeIfPresent(String.self, forKey: .height)
            aspect = try container.decodeIfPresent(BotsiImageAspect.self, forKey: .aspect) ?? .fit
            padding = try container.decodeIfPresent(BotsiEdge.self, forKey: .padding) ?? .defaultEdge
            
            if let offsetString = try? container.decodeIfPresent(String.self, forKey: .verticalOffset) {
                verticalOffset = offsetString
            } else if let offsetNumber = try? container.decodeIfPresent(Double.self, forKey: .verticalOffset) {
                verticalOffset = String(offsetNumber)
            } else if let offsetInt = try? container.decodeIfPresent(Int.self, forKey: .verticalOffset) {
                verticalOffset = String(offsetInt)
            } else {
                verticalOffset = nil
            }
        }
}
