//
//  BotsiUIToggleView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import Botsi
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct BotsiUIToggleView: View {
    @Environment(\.botsiScreenId)
    private var screenId: String

    @EnvironmentObject var paywallViewModel: BotsiPaywallViewModel
    @EnvironmentObject var productsViewModel: BotsiProductsViewModel
    @EnvironmentObject var actionsViewModel: BotsiUIActionsViewModel
    @EnvironmentObject var sectionsViewModel: BotsiSectionsViewModel
    @EnvironmentObject var screensViewModel: BotsiScreensViewModel

    private var toggle: VC.Toggle

    init(_ toggle: VC.Toggle) {
        self.toggle = toggle
    }

    var body: some View {
        Toggle(isOn: .init(get: {
            switch toggle.onCondition {
            case let .selectedSection(sectionId, sectionIndex):
                sectionIndex == sectionsViewModel.selectedIndex(for: sectionId)
            default: false
            }
        }, set: { value in
            (value ? toggle.onActions : toggle.offActions)
                .fire(
                    screenId: screenId,
                    paywallViewModel: paywallViewModel,
                    productsViewModel: productsViewModel,
                    actionsViewModel: actionsViewModel,
                    sectionsViewModel: sectionsViewModel,
                    screensViewModel: screensViewModel
                )
        })) {
            EmptyView()
        }
        .tint(toggle.color?.swiftuiColor)
    }
}

#if DEBUG

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
#Preview {
    BotsiUIToggleView(.create(sectionId: "toggle_preview"))
        .environmentObject(BotsiSectionsViewModel(logId: "Preview"))
}

#endif

#endif
