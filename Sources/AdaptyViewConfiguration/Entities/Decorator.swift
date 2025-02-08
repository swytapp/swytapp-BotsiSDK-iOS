//
//  Decorator.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension BotsiViewConfiguration {
    package struct Decorator: Sendable, Hashable {
        static let defaultShapeType: ShapeType = .rectangle(cornerRadius: CornerRadius.zero)
        package let shapeType: ShapeType
        package let background: Background?
        package let border: Border?
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.Decorator {
        static func create(
            shapeType: BotsiViewConfiguration.ShapeType = defaultShapeType,
            background: BotsiViewConfiguration.Background? = nil,
            border: BotsiViewConfiguration.Border? = nil
        ) -> Self {
            .init(
                shapeType: shapeType,
                background: background,
                border: border
            )
        }
    }
#endif
