//
//  BotsiLinksBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiLinksBlockView: View {
    private enum ButtonType: String {
        case termsOfService
        case privacyPolicy
        case restore
        case login
    }
    
    let model: BotsiLinksModel
    @EnvironmentObject var productViewModel: BotsiProductViewModel
    @EnvironmentObject var actionHandler: PaywallActionHandler
    
    public var body: some View {
        layoutStack {
            termsOfServiceIfNeeded
            privacyPolicyIfNeeded
            restoreButtonIfNeeded
            loginButtonIfNeeded
        }
        .padding(model.padding)
        .offset(y: model.verticalOffset.toCGFloat())
    }
}

// MARK: - Layout
@available(iOS 15.0, *)
private extension BotsiLinksBlockView {
    @ViewBuilder
    func layoutStack<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if model.contentLayout.layout == .horizontal {
            HStack(alignment: .center, spacing: model.contentLayout.spacing) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        } else {
            VStack(spacing: model.contentLayout.spacing) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

// MARK: - Links
@available(iOS 15.0, *)
private extension BotsiLinksBlockView {
    @ViewBuilder
    private var termsOfServiceIfNeeded: some View {
        if model.hasTermOfService, let tos = model.termOfService {
            button(for: tos, type: .termsOfService)
            addDividerIfNeeded(after: .termsOfService)
        }
    }
    
    @ViewBuilder
    private var privacyPolicyIfNeeded: some View {
        if model.hasPrivacyPolicy, let pp = model.privacyPolicy {
            button(for: pp, type: .privacyPolicy)
            addDividerIfNeeded(after: .privacyPolicy)
        }
    }
    
    @ViewBuilder
    private var restoreButtonIfNeeded: some View {
        if model.hasRestoreButton, let restore = model.restoreButton {
            button(for: restore, type: .restore)
            addDividerIfNeeded(after: .restore)
        }
    }
    
    @ViewBuilder
    private var loginButtonIfNeeded: some View {
        if model.hasLoginButton, let login = model.loginButton {
            button(for: login, type: .login)
        }
    }
    
    private func button(for item: BotsiLinksModel.LinkItem, type: ButtonType? = nil) -> some View {
        Button(action: {
            if let type = type {
                switch type {
                case .restore:
                    productViewModel.restorePurchases()
                case .login:
                    actionHandler.handleAction(.didLogin)
                case .termsOfService, .privacyPolicy:
                    if let url = item.url {
                        actionHandler.handleAction(.didOpenURL(url))
                    }
                }
            }
        }) {
            BotsiTextBlockView(
                propertiesProvider: model.style,
                text: item.text,
                align: .center,
                onOverflow: .scale
            )
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func addDividerIfNeeded(after buttonType: ButtonType) -> some View {
        let shouldShow = shouldAddDivider(for: buttonType)
        return Group {
            if shouldShow { dividerView }
        }
    }
    
    private func shouldAddDivider(for buttonType: ButtonType) -> Bool {
        // Don't show dividers for vertical layout
        guard model.contentLayout.layout == .horizontal else { return false }
        
        switch buttonType {
        case .termsOfService:
            return model.hasPrivacyPolicy || model.hasRestoreButton || model.hasLoginButton
        case .privacyPolicy:
            return model.hasRestoreButton || model.hasLoginButton
        case .restore:
            return model.hasLoginButton
        case .login:
            return false
        }
    }
}

// MARK: - Divider
@available(iOS 15.0, *)
private extension BotsiLinksBlockView {
    @ViewBuilder
    private var dividerView: some View {
        Rectangle()
            .fill(model.style.dividersColor?.toColor() ?? .clear)
            .frame(width: model.style.dividersThickness)
    }
}
