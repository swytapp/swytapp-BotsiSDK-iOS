//
//  BotsiUIActionsViewModel.swift
//
//
//  Created by Aleksey Goncharov on 21.05.2024.
//

#if canImport(UIKit)

import Botsi
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class BotsiUIActionsViewModel: ObservableObject {
    let logId: String
    let eventsHandler: BotsiEventsHandler

    package init(eventsHandler: BotsiEventsHandler) {
        self.eventsHandler = eventsHandler
        self.logId = eventsHandler.logId
    }

    func closeActionOccurred() {
        eventsHandler.event_didPerformAction(.close)
    }
    
    func openUrlActionOccurred(url urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else {
            Log.ui.warn("#\(logId)# can't parse url: \(urlString ?? "null")")
            return
        }
        eventsHandler.event_didPerformAction(.openURL(url: url))
    }
    
    func customActionOccurred(id: String) {
        eventsHandler.event_didPerformAction(.custom(id: id))
    }
}

#endif
