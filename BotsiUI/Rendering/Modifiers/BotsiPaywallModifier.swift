//
//  BotsiPaywallModifier.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 17.06.2025.
//

import SwiftUI
import Botsi

@MainActor
@available(iOS 15.0, *)
struct BotsiPaywallViewModifier: ViewModifier {
    private let isPresented: Binding<Bool>
    private let paywall: BotsiPaywall?
    private let builder: Botsi.BotsiBuilder?
    private let timerProvider: BotsiTimerProvider?
    private let purchaseDelegate: BotsiPurchaseDelegate?
    private let onAction: ((BotsiAction) -> Void)?
    private let onUIError: (BotsiUIError) -> Void
    
    init(
        isPresented: Binding<Bool>,
        paywall: BotsiPaywall?,
        builder: Botsi.BotsiBuilder?,
        timerProvider: BotsiTimerProvider? = nil,
        purchaseDelegate: BotsiPurchaseDelegate? = nil,
        onAction: ((BotsiAction) -> Void)? = nil,
        onUIError: @escaping (BotsiUIError) -> Void
    ) {
        self.isPresented = isPresented
        self.paywall = paywall
        self.builder = builder
        self.timerProvider = timerProvider
        self.purchaseDelegate = purchaseDelegate
        self.onAction = onAction
        self.onUIError = onUIError
    }
    
    @State private var paywallView: AnyView?
    
    @ViewBuilder
    private var paywallOrProgressView: some View {
        if let paywallView = paywallView {
            paywallView
        } else {
            BotsiUILoadingView()
        }
    }
    
    public func body(content: Content) -> some View {
        content
            .fullScreenCover(
                isPresented: isPresented,
                content: {
                    paywallOrProgressView
                        .task {
                            loadPaywall()
                        }
                        .onDisappear {
                            paywallView = nil
                        }
                }
            )
    }
    
    private func loadPaywall() {
        do {
            let view = try BotsiUI.makePaywall(
                paywall: paywall,
                builder: builder,
                purchaseDelegate: purchaseDelegate,
                onAction: onAction,
                timerProvider: timerProvider
            )
            paywallView = AnyView(view)
        } catch {
            if let uiError = error as? BotsiUIError {
                onUIError(uiError)
            } else {
                onUIError(BotsiUIError.contentParsingError)
            }
        }
    }
}

@available(iOS 15.0, *)
@MainActor
public extension View {
    /// Presents a paywall when a binding to a Boolean value that you
    /// provide is true.
    ///
    /// - Parameters:
    ///     - isPresented: A binding to a Boolean value that determines whether
    ///     to present the paywall.
    ///     - paywall: BotsiPaywall object containing paywall object.
    ///     - builder: JSON data containing paywall structure.
    ///     - timerProvider: Optional timer provider for countdown functionality.
    ///     - purchaseDelegate: Optional delegate to override default purchase and restore behavior.
    ///       Use this to integrate with RevenueCat or other payment processors.
    ///     - onAction: Optional callback for handling paywall actions.
    ///     - onUIError: Required callback for handling UI errors.
    ///
    /// - Example with custom purchase delegate:
    /// ```swift
    /// struct MyRevenueCatDelegate: BotsiPurchaseDelegate {
    ///     func handlePurchase(_ product: BotsiProduct) async -> BotsiPurchaseResult {
    ///         // Use RevenueCat instead of Botsi's StoreKit
    ///         let result = try await Purchases.shared.purchase(...)
    ///         return .success(profile)
    ///     }
    ///
    ///     func handleRestore() async -> BotsiRestoreResult {
    ///         let result = try await Purchases.shared.restorePurchases()
    ///         return .success(profile)
    ///     }
    /// }
    ///
    /// // Usage:
    /// .botsiPaywall(
    ///     isPresented: $showPaywall,
    ///     paywall: paywall,
    ///     builder: builder,
    ///     purchaseDelegate: MyRevenueCatDelegate(),
    ///     onAction: handleAction,
    ///     onUIError: handleError
    /// )
    /// ```
    func botsiPaywall(
        isPresented: Binding<Bool>,
        paywall: BotsiPaywall?,
        builder: Botsi.BotsiBuilder?,
        timerProvider: BotsiTimerProvider? = nil,
        purchaseDelegate: BotsiPurchaseDelegate? = nil,
        onAction: ((BotsiAction) -> Void)? = nil,
        onUIError: @escaping (BotsiUIError) -> Void
    ) -> some View {
        modifier(
            BotsiPaywallViewModifier(
                isPresented: isPresented,
                paywall: paywall,
                builder: builder,
                timerProvider: timerProvider,
                purchaseDelegate: purchaseDelegate,
                onAction: onAction,
                onUIError: onUIError
            )
        )
    }
}
