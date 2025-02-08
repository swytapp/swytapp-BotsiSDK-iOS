//
//  BotsimageUrlObserver.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 03.04.2024
//
//

import Foundation

package protocol BotsiImageUrlObserver: Sendable {
    func extractedImageUrls(_: Set<URL>)
}

extension Botsi {
    private actor Holder {
        private(set) var imageUrlObserver: BotsiImageUrlObserver?

        func set(imageUrlObserver observer: BotsiImageUrlObserver) {
            imageUrlObserver = observer
        }
    }

    private static let holder = Holder()

    package nonisolated static func setImageUrlObserver(_ observer: BotsiImageUrlObserver) {
        Task {
            await holder.set(imageUrlObserver: observer)
        }
    }

    static func sendImageUrlsToObserver(_ config: BotsiViewSource) {
        Task {
            guard let observer = await holder.imageUrlObserver else { return }
            let urls = config.extractImageUrls(config.responseLocale)
            guard !urls.isEmpty else { return }
            observer.extractedImageUrls(urls)
        }
    }

    private static func sendImageUrlsToObserver(_ config: BotsiPaywall.ViewConfiguration) {
        guard case let .data(value) = config else { return }
        sendImageUrlsToObserver(value)
    }

    static func sendImageUrlsToObserver(_ paywall: BotsiPaywall) {
        guard let config = paywall.viewConfiguration else { return }
        sendImageUrlsToObserver(config)
    }
}
