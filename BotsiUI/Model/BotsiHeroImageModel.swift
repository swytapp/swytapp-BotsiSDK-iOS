//
//  BotsiHeroImageModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiHeroImageModel: Decodable, Sendable {
    public let type: String          // "image"
    public let style: String          // "overlay" | etc
    public let backgroundImage: String
    public let height: CGFloat
    public let shape: String          // "rectangle" | …
    public let tint: Tint?
    public let layout: Layout

    public struct Tint: Decodable, Sendable {
        public let opacity: Int
        public let fillColor: String
        private enum CodingKeys: String, CodingKey {
            case opacity
            case fillColor = "fill_color"
        }
    }
    public struct Layout: Decodable, Sendable {
        public let padding: String
        public let verticalOffset: String
        
        private enum CodingKeys: String, CodingKey {
            case padding
            case verticalOffset = "vertical_offset"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case height, shape, tint, layout, type, style
        case backgroundImage = "background_image"
    }
}
