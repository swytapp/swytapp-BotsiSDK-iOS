//
//  BotsiPaywallViewModel.swift
//
//
//  Created by Aleksey Goncharov on 27.06.2024.
//

#if canImport(UIKit)

import Botsi
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class BotsiPaywallViewModel: ObservableObject {
    let logId: String
    let eventsHandler: BotsiEventsHandler

    @Published var paywall: BotsiPaywallInterface
    @Published var viewConfiguration: BotsiViewConfiguration

    var onViewConfigurationUpdate: ((BotsiViewConfiguration) -> Void)?

    package init(
        eventsHandler: BotsiEventsHandler,
        paywall: BotsiPaywallInterface,
        viewConfiguration: BotsiViewConfiguration
    ) {
        self.logId = eventsHandler.logId
        self.eventsHandler = eventsHandler
        self.paywall = paywall
        self.viewConfiguration = viewConfiguration
    }

    private var logShowPaywallCalled = false
    
    func logShowPaywall() {
        guard !logShowPaywallCalled else { return }
        logShowPaywallCalled = true
        
        let logId = logId
        Log.ui.verbose("#\(logId)# logShowPaywall begin")

        Task {
            do {
                try await paywall.logShowPaywall(viewConfiguration: viewConfiguration)
                Log.ui.verbose("#\(logId)# logShowPaywall success")
            } catch {
                Log.ui.error("#\(logId)# logShowPaywall fail: \(error)")
            }
        }
    }
    
    func resetLogShowPaywall() {
        Log.ui.verbose("#\(logId)# resetLogShowPaywall")
        logShowPaywallCalled = false
    }

    func reloadData() {
        Task { @MainActor in
            do {
                Log.ui.verbose("#\(logId)# paywall reloadData begin")
                
                let paywall = try await Botsi.getPaywall(placementId: paywall.placementId, locale: paywall.locale)
                let viewConfiguration = try await Botsi.getViewConfiguration(paywall: paywall)
                
                self.paywall = paywall
                self.viewConfiguration = viewConfiguration
                
                onViewConfigurationUpdate?(viewConfiguration)
            } catch {
                Log.ui.error("#\(logId)# paywall reloadData fail: \(error)")
            }
        }
    }
}

#endif
