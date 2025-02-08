//
//  Border.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension BotsiViewConfiguration {
    struct Border: Sendable, Hashable {
        static let `default` = Border(
            filling: .same(.solidColor(BotsiViewConfiguration.Color.transparent)),
            thickness: 1.0
        )

        package let filling: Mode<Filling>
        package let thickness: Double
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.Border {
        static func create(
            filling: BotsiViewConfiguration.Mode<BotsiViewConfiguration.Filling> = `default`.filling,
            thickness: Double = `default`.thickness
        ) -> Self {
            .init(filling: filling, thickness: thickness)
        }
    }
#endif
