//
//  BotsiHeroImageModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiHeroImageModel: Decodable, Sendable {
    public let type: String
    public let style: HeroImageType
    public let backgroundImage: String
    public let height: CGFloat
    public let shape: BotsiHeroShapeType
    public let fillColor: BotsiFillColor?
    public let layout: Layout
    
    public var heightPercent: CGFloat {
        return height / 100
    }

    public struct Layout: Decodable, Sendable {
        public let padding: BotsiEdge
        public let verticalOffset: String
        
        private enum CodingKeys: String, CodingKey {
            case padding
            case verticalOffset = "vertical_offset"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case height, shape, layout, type, style
        case backgroundImage = "background_image"
        case fillColor = "fill_color"
    }
}

public enum HeroImageType: String, Decodable, Sendable {
    case transparent
    case overlay
    case flat
}

public enum BotsiHeroShapeType: String, Decodable, Sendable {
    case rectangle, circle
    case convexMask = "convex_mask"
    case concaveMask = "concave_mask"
    case roundedRectangle = "rounded_rectangle"
    case leafSape = "leaf"
}

// MARK: - Mask Shapes

private struct ConvexMaskShape: Shape {
    var curveHeight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + curveHeight))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + curveHeight),
            control: CGPoint(x: rect.midX, y: rect.minY - curveHeight)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

private struct ConcaveMaskShape: Shape {
    let curveHeight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + curveHeight))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + curveHeight),
            control: CGPoint(x: rect.midX, y: rect.minY + curveHeight * 2)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

private struct LeafMaskShape: Shape {
    
    struct Corners: OptionSet, Sendable {
        public let rawValue: Int

        public static let topLeft     = Corners(rawValue: 1 << 0)
        public static let topRight    = Corners(rawValue: 1 << 1)
        public static let bottomLeft  = Corners(rawValue: 1 << 2)
        public static let bottomRight = Corners(rawValue: 1 << 3)

        public static let all: Corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    let radius: CGFloat
    let corners: Corners

    init(radius: CGFloat, corners: Corners) {
        self.radius = radius
        self.corners = corners
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let tl = corners.contains(.topLeft) ? radius : 0
        let tr = corners.contains(.topRight) ? radius : 0
        let bl = corners.contains(.bottomLeft) ? radius : 0
        let br = corners.contains(.bottomRight) ? radius : 0

        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))

        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        if tr > 0 {
            path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                        radius: tr,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(0),
                        clockwise: false)
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        if br > 0 {
            path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                        radius: br,
                        startAngle: .degrees(0),
                        endAngle: .degrees(90),
                        clockwise: false)
        }

        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        if bl > 0 {
            path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
                        radius: bl,
                        startAngle: .degrees(90),
                        endAngle: .degrees(180),
                        clockwise: false)
        }

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        if tl > 0 {
            path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                        radius: tl,
                        startAngle: .degrees(180),
                        endAngle: .degrees(270),
                        clockwise: false)
        }

        path.closeSubpath()

        return path
    }
}

// MARK: - View Extension

@available(iOS 15.0, *)
public extension View {
    @ViewBuilder
    func mask(with shape: BotsiHeroShapeType?, size: CGSize = .zero, isContainer: Bool = false) -> some View {
        switch shape {
        case .rectangle:
            self
        case .roundedRectangle:
            if isContainer {
                if #available(iOS 16.0, *) {
                    self.clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                } else {
                    self.clipShape(RoundedCorners(cornerRadius: 20, corners: [.topLeft, .topRight]))
                }
            } else {
                self.clipShape(RoundedRectangle(cornerRadius: size.height * 0.08))
            }
        case .circle where size.height > size.width:
            self.clipShape(.ellipse)
        case .circle:
            self.clipShape(.circle)
        case .leafSape:
            self.clipShape(LeafMaskShape(radius: size.height * 0.25, corners: [.topLeft, .bottomRight]))
        case .convexMask:
            self.clipShape(ConvexMaskShape(curveHeight: 10))
        case .concaveMask:
            self.clipShape(ConcaveMaskShape(curveHeight: 30))
        default:
            self
        }
    }
}
