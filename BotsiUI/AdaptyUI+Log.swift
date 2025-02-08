//
//  BotsiUI+Log.swift
//
//
//  Created by Alexey Goncharov on 2023-01-25.
//

import Botsi

extension Log {
    static func Category(name: String) -> BotsiLog.Category {
        BotsiLog.Category(subsystem: "io.botsi.ui", name: name)
    }

    static let ui = Category(name: "ui")
    static let cache = Category(name: "BotsiMediaCache")
    static let prefetcher = Category(name: "ImageUrlPrefetcher")
}
