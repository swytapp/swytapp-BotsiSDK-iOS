//
//  Transition.Slide.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

extension BotsiViewConfiguration {
    package struct TransitionSlide: Sendable, Hashable {
        static let `default` = BotsiViewConfiguration.TransitionSlide(
            startDelay: 0.0,
            duration: 0.3,
            interpolator: BotsiViewConfiguration.Transition.Interpolator.default
        )

        package let startDelay: TimeInterval
        package let duration: TimeInterval
        package let interpolator: BotsiViewConfiguration.Transition.Interpolator
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.TransitionSlide {
        static func create(
            startDelay: TimeInterval = `default`.startDelay,
            duration: TimeInterval = `default`.duration,
            interpolator: BotsiViewConfiguration.Transition.Interpolator = `default`.interpolator
        ) -> Self {
            .init(
                startDelay: startDelay,
                duration: duration,
                interpolator: interpolator
            )
        }
    }
#endif

extension BotsiViewConfiguration.TransitionSlide: Decodable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case duration
        case interpolator
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        startDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? BotsiViewConfiguration.TransitionSlide.default.startDelay
        duration = try (container.decodeIfPresent(TimeInterval.self, forKey: .duration)).map { $0 / 1000.0 } ?? BotsiViewConfiguration.TransitionSlide.default.duration
        interpolator = try (container.decodeIfPresent(BotsiViewConfiguration.Transition.Interpolator.self, forKey: .interpolator)) ?? BotsiViewConfiguration.TransitionSlide.default.interpolator
    }
}
