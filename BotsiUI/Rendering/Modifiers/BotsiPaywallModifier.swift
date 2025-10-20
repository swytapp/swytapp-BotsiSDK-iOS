//
//  BotsiPaywallModifier.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 17.06.2025.
//

import SwiftUI
import Botsi

@available(iOS 15.0, *)
@MainActor
public struct BotsiLoadingPlaceholderView: View {
    public init() {}
    
    public var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
    }
}

@MainActor
@available(iOS 15.0, *)
struct BotsiPaywallViewModifier: ViewModifier {
    private let isPresented: Binding<Bool>
    private let paywall: BotsiPaywall?
    private let builder: Botsi.BotsiBuilder?
    private let timerProvider: BotsiTimerProvider?
    private let onAction: ((BotsiAction) -> Void)?
    private let onUIError: (BotsiUIError) -> Void
    
    init(
        isPresented: Binding<Bool>,
        paywall: BotsiPaywall?,
        builder: Botsi.BotsiBuilder?,
        timerProvider: BotsiTimerProvider? = nil,
        onAction: ((BotsiAction) -> Void)? = nil,
        onUIError: @escaping (BotsiUIError) -> Void
    ) {
        self.isPresented = isPresented
        self.paywall = paywall
        self.builder = builder
        self.timerProvider = timerProvider
        self.onAction = onAction
        self.onUIError = onUIError
    }
    
    @State private var paywallView: AnyView?
    
    @ViewBuilder
    private var paywallOrProgressView: some View {
        if let paywallView = paywallView {
            paywallView
        } else {
            BotsiLoadingPlaceholderView()
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
    ///     - onAction: Optional callback for handling paywall actions.
    ///     - onUIError: Required callback for handling UI errors.
    func botsiPaywall(
        isPresented: Binding<Bool>,
        paywall: BotsiPaywall?,
        builder: Botsi.BotsiBuilder?,
        timerProvider: BotsiTimerProvider? = nil,
        onAction: ((BotsiAction) -> Void)? = nil,
        onUIError: @escaping (BotsiUIError) -> Void
    ) -> some View {
        modifier(
            BotsiPaywallViewModifier(
                isPresented: isPresented,
                paywall: paywall,
                builder: builder,
                timerProvider: timerProvider,
                onAction: onAction,
                onUIError: onUIError
            )
        )
    }
}
