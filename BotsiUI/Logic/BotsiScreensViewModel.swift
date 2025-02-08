//
//  BotsiScreensViewModel.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import Botsi
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class BotsiBottomSheetViewModel: ObservableObject {
    @Published var isPresented: Bool = false

    var id: String
    var bottomSheet: VC.BottomSheet

    init(id: String, bottomSheet: VC.BottomSheet) {
        self.id = id
        self.bottomSheet = bottomSheet
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class BotsiScreensViewModel: ObservableObject {
    let logId: String
    let eventsHandler: BotsiEventsHandler
    let viewConfiguration: BotsiViewConfiguration
    let bottomSheetsViewModels: [BotsiBottomSheetViewModel]

    @Published var presentedScreensStack = [String]()

    package init(
        eventsHandler: BotsiEventsHandler,
        viewConfiguration: BotsiViewConfiguration
    ) {
        self.eventsHandler = eventsHandler
        logId = eventsHandler.logId
        self.viewConfiguration = viewConfiguration

        bottomSheetsViewModels = viewConfiguration.bottomSheets.map {
            .init(id: $0.key, bottomSheet: $0.value)
        }
    }

    func presentScreen(id: String) {
        Log.ui.verbose("#\(logId)# presentScreen \(id)")

        if presentedScreensStack.contains(where: { $0 == id }) {
            Log.ui.warn("#\(logId)# presentScreen \(id) Already Presented!")
            return
        }

        for bottomSheetVM in bottomSheetsViewModels {
            if bottomSheetVM.id == id {
                bottomSheetVM.isPresented = true
                presentedScreensStack.append(id)
            }
        }
    }

    func dismissScreen(id: String) {
        Log.ui.verbose("#\(logId)# dismissScreen \(id)")
        presentedScreensStack.removeAll(where: { $0 == id })

        for bottomSheetVM in bottomSheetsViewModels {
            if bottomSheetVM.id == id {
                bottomSheetVM.isPresented = false
            }
        }
    }

    func dismissTopScreen() {
        guard let topScreenId = presentedScreensStack.last else { return }

        dismissScreen(id: topScreenId)
    }
}

#endif
