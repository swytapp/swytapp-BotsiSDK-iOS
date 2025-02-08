//
//  BotsiUIButtonView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Botsi
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct BotsiUIButtonView: View {
    @Environment(\.botsiScreenId)
    private var screenId: String

    private var button: VC.Button

    @EnvironmentObject var paywallViewModel: BotsiPaywallViewModel
    @EnvironmentObject var productsViewModel: BotsiProductsViewModel
    @EnvironmentObject var actionsViewModel: BotsiUIActionsViewModel
    @EnvironmentObject var sectionsViewModel: BotsiSectionsViewModel
    @EnvironmentObject var screensViewModel: BotsiScreensViewModel

    init(_ button: VC.Button) {
        self.button = button
    }

    private var currentStateView: VC.Element {
        guard let selectedCondition = button.selectedCondition else {
            return button.normalState
        }

        switch selectedCondition {
        case let .selectedSection(sectionId, sectionIndex):
            if sectionIndex == sectionsViewModel.selectedIndex(for: sectionId) {
                return button.selectedState ?? button.normalState
            } else {
                return button.normalState
            }
        case let .selectedProduct(productId, productsGroupId):
            if productId == productsViewModel.selectedProductId(by: productsGroupId) {
                return button.selectedState ?? button.normalState
            } else {
                return button.normalState
            }
        }
    }

    public var body: some View {
        Button {
            for action in button.actions {
                action.fire(
                    screenId: screenId,
                    paywallViewModel: paywallViewModel,
                    productsViewModel: productsViewModel,
                    actionsViewModel: actionsViewModel,
                    sectionsViewModel: sectionsViewModel,
                    screensViewModel: screensViewModel
                )
            }
        } label: {
            BotsiUIElementView(currentStateView)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension [VC.ActionAction] {
    func fire(
        screenId: String,
        paywallViewModel: BotsiPaywallViewModel,
        productsViewModel: BotsiProductsViewModel,
        actionsViewModel: BotsiUIActionsViewModel,
        sectionsViewModel: BotsiSectionsViewModel,
        screensViewModel: BotsiScreensViewModel
    ) {
        forEach {
            $0.fire(
                screenId: screenId,
                paywallViewModel: paywallViewModel,
                productsViewModel: productsViewModel,
                actionsViewModel: actionsViewModel,
                sectionsViewModel: sectionsViewModel,
                screensViewModel: screensViewModel
            )
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.ActionAction {
    func fire(
        screenId: String,
        paywallViewModel: BotsiPaywallViewModel,
        productsViewModel: BotsiProductsViewModel,
        actionsViewModel: BotsiUIActionsViewModel,
        sectionsViewModel: BotsiSectionsViewModel,
        screensViewModel: BotsiScreensViewModel
    ) {
        switch self {
        case let .selectProduct(id, groupId):
            withAnimation(.linear(duration: 0.0)) {
                productsViewModel.selectProduct(id: id, forGroupId: groupId)
            }
        case let .unselectProduct(groupId):
            productsViewModel.unselectProduct(forGroupId: groupId)
        case let .purchaseSelectedProduct(groupId):
            productsViewModel.purchaseSelectedProduct(fromGroupId: groupId)
        case let .purchaseProduct(productId):
            productsViewModel.purchaseProduct(id: productId)
        case .restore:
            productsViewModel.restorePurchases()
        case let .switchSection(sectionId, index):
            withAnimation(.linear(duration: 0.0)) {
                sectionsViewModel.updateSelection(for: sectionId, index: index)
            }
        case let .openScreen(id):
            withAnimation(.linear(duration: 0.3)) {
                screensViewModel.presentScreen(id: id)
            }
        case .closeScreen:
            screensViewModel.dismissScreen(id: screenId)
        case .close:
            actionsViewModel.closeActionOccurred()
        case let .openUrl(url):
            actionsViewModel.openUrlActionOccurred(url: url)
        case let .custom(id):
            switch id {
            case "$botsi_reload_data":
                paywallViewModel.reloadData()
            default:
                actionsViewModel.customActionOccurred(id: id)
            }
        }
    }
}

#endif
