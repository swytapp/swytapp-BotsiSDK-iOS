//
//  BotsiProductViewModel.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 15.10.2025.
//

import Foundation
import Botsi

@MainActor
@available(iOS 15.0, *)
final class BotsiProductViewModel: ObservableObject {
    private let actionHandler: PaywallActionHandler
    private let paywall: BotsiPaywall
    @Published var selectedProductId: Int?

    init(actionHandler: PaywallActionHandler, paywall: BotsiPaywall) {
        self.actionHandler = actionHandler
        self.paywall = paywall
    }

    func makeSelectedPurchase() {
        Task {
            guard let selectedProductId = selectedProductId else {
                return
            }

            await handlePurchase(id: selectedProductId)
        }
    }

    func makePurchase(productId: Int?) {
        Task {
            guard let id = productId else {
                return
            }

            await handlePurchase(id: id)
        }
    }

    func restorePurchases() {
        Task {
            do {
                let profile = try await Botsi.restorePurchases()
                actionHandler.handleAction(.didRestorePurchase(profile))
            } catch {
                actionHandler.handleAction(.didFailRestorePurchases(BotsiError.restoreFailed))
            }
        }
    }

    func selectProduct(productId: Int?) {
        selectedProductId = productId

        Task {
            guard let productId, let product = await getProduct(byId: productId) else {
                return
            }
             actionHandler.handleAction(.didSelectProduct(product))
        }
    }

     private func handlePurchase(id: Int?) async {
        guard let id, let product = await getProduct(byId: id) else {
            return
        }

        do {
            let profile = try await Botsi.makePurchase(product)
            actionHandler.handleAction(.didPurchase(profile))
        } catch {
            actionHandler.handleAction(.didFailPurchase(nil, BotsiError.purchaseFailed(error.localizedDescription)))
        }
     }

    private func getProduct(byId id: Int) async -> BotsiProduct? {
        guard let appleProductId = paywall.sourceProducts.first(where: { $0.botsiProductId == id })?.sourcePoductId else {
            return nil
        }

        let products = try? await Botsi.getPaywallProducts(from: paywall)

        guard let product = products?.first(where: { $0.productId == appleProductId }) else {
            return nil
        }

        return product
    }
}
