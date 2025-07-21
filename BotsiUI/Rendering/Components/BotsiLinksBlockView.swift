//
//  BotsiLinksBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiLinksBlockView: View {
    
    let model: BotsiLinksModel
    let onLinkTap: (String) -> Void
    
    public var body: some View {
        layoutStack {
            ForEach(linkButtons, id: \.id) { item in
                item.view
                if item.id != linkButtons.last?.id {
                    dividerView
                }
            }
        }
        .padding(.leading, model.padding?.left)
        .padding(.top, model.padding?.top)
        .padding(.trailing, model.padding?.right)
        .padding(.bottom, model.padding?.bottom)
        .offset(y: CGFloat(Double(model.verticalOffset) ?? 0))
    }

    private var linkButtons: [(id: String, view: AnyView)] {
        var items: [(String, AnyView)] = []
        
        if model.hasTermOfService, let tos = model.termOfService {
            items.append((tos.text, AnyView(linkButton(for: tos))))
        }
        if model.hasPrivacyPolicy, let pp = model.privacyPolicy {
            items.append((pp.text, AnyView(linkButton(for: pp))))
        }
        if model.hasRestoreButton, let restore = model.restoreButton {
            items.append((restore.text, AnyView(actionButton(for: restore, type: "restore"))))
        }
        if model.hasLoginButton, let login = model.loginButton {
            items.append((login.text, AnyView(actionButton(for: login, type: "login"))))
        }
        return items
    }

    @ViewBuilder
    private func layoutStack<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if model.contentLayout.layout == .horizontal {
            HStack(alignment: .center, spacing: model.contentLayout.spacing?.toCGFloat() ?? 8) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        } else {
            VStack(spacing: model.contentLayout.spacing?.toCGFloat() ?? 8) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func linkButton(for item: BotsiLinksModel.LinkItem) -> some View {
        Button(action: {
            onLinkTap(item.url ?? item.text)
        }) {
            Text(item.text)
                .font(.system(size: model.style.size.toCGFloat() ?? 12))
                .foregroundFill(model.style.color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }

    private func actionButton(for item: BotsiLinksModel.LinkItem, type: String) -> some View {
        Button(action: {
            onLinkTap(type)
        }) {
            Text(item.text)
                .font(.system(size: model.style.size.toCGFloat() ?? 12))
                .foregroundFill(model.style.color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }

    @ViewBuilder
    private var dividerView: some View {
        Rectangle()
            .fill(Color(hex: model.style.dividersColor ?? "#ffffff")
                .opacity(Double(model.style.dividersOpacity?.toCGFloat() ?? 0) ?? 100 / 100))
            .frame(width: model.contentLayout.layout == .horizontal ? 1 : nil,
                   height: model.contentLayout.layout == .horizontal ? nil : 1)
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
    }
}
