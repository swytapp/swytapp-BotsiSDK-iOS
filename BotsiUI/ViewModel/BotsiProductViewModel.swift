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
    @Published private(set) var selectedProductId: Int?
    @Published private(set) var isLoading = false
    @Published var isBottomProductSheetPresented = false

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
            isLoading = true
            
            // Check if developer provided custom restore delegate
            if let delegate = actionHandler.purchaseDelegate {
                let result = await delegate.handleRestore()
                
                switch result {
                case .success(let profile):
                    isLoading = false
                    await delegate.didCompleteRestore(profile)
                    actionHandler.handleAction(.didRestorePurchase(profile))
                    
                case .failure(let error):
                    isLoading = false
                    let botsiError = (error as? BotsiError) ?? BotsiError.restoreFailed
                    actionHandler.handleAction(.didFailRestorePurchases(botsiError))
                }
            } else {
                // Fall back to default Botsi restore behavior
                do {
                    let profile = try await Botsi.restorePurchases()
                    isLoading = false
                    actionHandler.handleAction(.didRestorePurchase(profile))
                } catch {
                    isLoading = false
                    actionHandler.handleAction(.didFailRestorePurchases(BotsiError.restoreFailed))
                }
            }
        }
    }

    func selectProduct(productId: Int?, withEvent: Bool = true) {
        selectedProductId = productId

        if withEvent {
            Task {
                guard let productId, let product = await getProduct(byId: productId) else {
                    return
                }
                actionHandler.handleAction(.didSelectProduct(product))
            }
        }
    }

     private func handlePurchase(id: Int?) async {
        isLoading = true
        guard let id, let product = await getProduct(byId: id) else {
            isLoading = false
            return
        }
        
        // Check if developer provided custom purchase delegate
        if let delegate = actionHandler.purchaseDelegate {
            // Check if purchase should proceed (optional validation)
            let shouldProceed = await delegate.shouldPurchase(product)
            guard shouldProceed else {
                isLoading = false
                return
            }
            
            // Use custom purchase handler
            let result = await delegate.handlePurchase(product)
            
            switch result {
            case .success(let profile):
                isLoading = false
                await delegate.didCompletePurchase(product, profile: profile)
                actionHandler.handleAction(.didPurchase(profile))
                
            case .failure(let error):
                isLoading = false
                let botsiError = (error as? BotsiError) ?? BotsiError.purchaseFailed(error.localizedDescription)
                actionHandler.handleAction(.didFailPurchase(product, botsiError))
                
            case .cancelled:
                isLoading = false
                // User cancelled - just stop loading, don't trigger error
            }
        } else {
            // Fall back to default Botsi purchase behavior
            do {
                let profile = try await Botsi.makePurchase(product)
                isLoading = false
                actionHandler.handleAction(.didPurchase(profile))
            } catch {
                isLoading = false
                actionHandler.handleAction(.didFailPurchase(product, BotsiError.purchaseFailed(error.localizedDescription)))
            }
        }
     }

    private func getProduct(byId id: Int) async -> BotsiProduct? {
        guard let appleProductId = paywall.sourceProducts.first(where: { $0.botsiProductId == id })?.sourceProductId else {
            return nil
        }

        let products = try? await Botsi.getPaywallProducts(from: paywall)

        guard let product = products?.first(where: { $0.productId == appleProductId }) else {
            return nil
        }

        return product
    }
}
