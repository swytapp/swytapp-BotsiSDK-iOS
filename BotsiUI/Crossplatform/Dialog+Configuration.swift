//
//  Dialog+Configuration.swift
//  Botsi
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension BotsiUI.DialogConfiguration {
    struct Action {
        package let title: String
        package init(title: String) {
            self.title = title
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension BotsiUI {
    struct DialogConfiguration {
        package let title: String?
        package let content: String?
        package let defaultAction: BotsiUI.DialogConfiguration.Action
        package let secondaryAction: BotsiUI.DialogConfiguration.Action?

        package init(
            title: String?,
            content: String?,
            defaultActionTitle: String,
            secondaryActionTitle: String?
        ) {
            self.title = title
            self.content = content
            self.defaultAction = .init(title: defaultActionTitle)
            self.secondaryAction = secondaryActionTitle.map(BotsiUI.DialogConfiguration.Action.init)
        }
    }
}
