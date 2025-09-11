//
//  BotsiCarouselModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiCarouselModel: Decodable, Sendable, BotsiPaddingProvider {
    
    public let height: CGFloat
    public let pageControl: Bool
    public let style: IndicatorStyle
    public let slideShow: Bool
    public let timing: Timing
    public let backgroundImage: String
    public let padding: BotsiEdge   
    public let verticalOffset: CGFloat
    public let contentPadding: BotsiEdge
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
        style = try container.decode(IndicatorStyle.self, forKey: .style)
        slideShow = try container.decode(Bool.self, forKey: .slideShow)
        timing = try container.decode(Timing.self, forKey: .timing)
        backgroundImage = try container.decodeIfPresent(String.self, forKey: .backgroundImage) ?? ""
        padding = try container.decodeIfPresent(BotsiEdge.self, forKey: .padding) ?? .defaultEdge
        verticalOffset = try container.decodeCGFloat(forKey: .verticalOffset)
        contentPadding = try container.decodeIfPresent(BotsiEdge.self, forKey: .contentPadding) ?? .defaultEdge
        spacing = try container.decodeCGFloat(forKey: .spacing)
    }

    public struct IndicatorStyle: Decodable, Sendable {
        public let activeColor: BotsiFillColor
        public let defaultColor: BotsiFillColor
        public let size: CGFloat
        public let placement: DotPlacement
        public let padding: BotsiEdge
        public let spacing: CGFloat

        private enum CodingKeys: String, CodingKey {
            case activeColor = "active_color"
            case defaultColor = "default_color"
            case size
            case placement = "size_option"
            case padding
            case spacing
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            activeColor = try container.decode(BotsiFillColor.self, forKey: .activeColor)
            defaultColor = try container.decode(BotsiFillColor.self, forKey: .defaultColor)
            size = try container.decodeCGFloat(forKey: .size)
            placement = try container.decode(DotPlacement.self, forKey: .placement)
            padding = try container.decodeIfPresent(BotsiEdge.self, forKey: .padding) ?? .defaultEdge
            spacing = try container.decodeCGFloat(forKey: .spacing)
        }
    }

    public struct Timing: Decodable, Sendable {
        public let timing: Int
        public let initialTiming: Int
        public let transition: Int
        public let lastOption: LastOption
        public let interactive: InteractiveOption

        private enum CodingKeys: String, CodingKey {
            case timing, transition, interactive
            case initialTiming = "initial_timing"
            case lastOption = "last_option"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            timing = try container.decodeInt(forKey: .timing)
            initialTiming = try container.decodeInt(forKey: .initialTiming)
            transition = try container.decodeInt(forKey: .transition)
            lastOption = try container.decode(LastOption.self, forKey: .lastOption)
            interactive = try container.decode(InteractiveOption.self, forKey: .interactive)
        }
    }
    
    public enum LastOption: String, Codable, Sendable {
        case startOver = "start over"
        case stop = "stop slide show"
    }
    
    public enum InteractiveOption: String, Codable, Sendable {
        case nonInteractive = "without_affect"
        case pause = "pause"
        case stop = "stop"
    }

    public enum DotPlacement: String, Codable, Sendable {
        case overlay = "overlay"
        case outside = "outside"
    }
}
