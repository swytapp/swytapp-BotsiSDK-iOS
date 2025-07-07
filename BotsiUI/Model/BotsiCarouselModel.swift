//
//  BotsiCarouselModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiCarouselModel: Decodable, Sendable {
    
    public let height: CGFloat
    public let pageControl: Bool
    public let style: PageStyle
    public let slideShow: Bool
    public let timing: Timing?
    public let backgroundImage: String
    public let padding: CGFloat
    public let verticalOffset: CGFloat
    public let contentPadding: CGFloat
    public let spacing: CGFloat

    private enum CodingKeys: String, CodingKey {
        case height, timing, style, spacing
        case pageControl = "page_control"
        case slideShow = "slide_show"
        case backgroundImage = "background_image"
        case padding = "padding"
        case verticalOffset = "vertical_offset"
        case contentPadding = "content_padding"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        height = try container.decodeCGFloat(forKey: .height)
        pageControl = try container.decode(Bool.self, forKey: .pageControl)
        style = try container.decode(PageStyle.self, forKey: .style)
        slideShow = try container.decode(Bool.self, forKey: .slideShow)
        timing = try? container.decode(Timing.self, forKey: .timing)
        backgroundImage = try container.decode(String.self, forKey: .backgroundImage)
        padding = try container.decodeCGFloat(forKey: .padding)
        verticalOffset = try container.decodeCGFloat(forKey: .verticalOffset)
        contentPadding = try container.decodeCGFloat(forKey: .contentPadding)
        spacing = try container.decodeCGFloat(forKey: .spacing)
    }

    public struct PageStyle: Decodable, Sendable {
        public let activeColor: String
        public let defaultColor: String
        public let activeOpacity: Int
        public let defaultOpacity: Int
        public let size: CGFloat
        public let sizeOption: String
        public let padding: CGFloat
        public let spacing: CGFloat

        private enum CodingKeys: String, CodingKey {
            case activeColor = "active_color"
            case defaultColor = "default_color"
            case activeOpacity = "active_opacity"
            case defaultOpacity = "default_opacity"
            case size
            case sizeOption = "size_option"
            case padding
            case spacing
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            activeColor = try container.decode(String.self, forKey: .activeColor)
            defaultColor = try container.decode(String.self, forKey: .defaultColor)
            activeOpacity = try container.decode(Int.self, forKey: .activeOpacity)
            defaultOpacity = try container.decode(Int.self, forKey: .defaultOpacity)
            size = try container.decodeCGFloat(forKey: .size)
            sizeOption = try container.decode(String.self, forKey: .sizeOption)
            padding = try container.decodeCGFloat(forKey: .padding)
            spacing = try container.decodeCGFloat(forKey: .spacing)
        }
    }

    public struct Timing: Codable, Sendable {
        public let timing: Int?
        public let initialTiming: Int?
        public let transition: Int?
        public let lastOption: String?
        public let interactive: String?

        private enum CodingKeys: String, CodingKey {
            case timing, transition, interactive
            case initialTiming = "initial_timing"
            case lastOption = "last_option"
        }
    }
}

extension KeyedDecodingContainer {
    func decodeCGFloat(forKey key: Key) throws -> CGFloat {
        if let doubleValue = try? decode(Double.self, forKey: key) {
            return CGFloat(doubleValue)
        }
        if let stringValue = try? decode(String.self, forKey: key),
           let doubleValue = Double(stringValue) {
            return CGFloat(doubleValue)
        }
        return 0
    }
}
