//
//  TopButtonsOverlayView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 23.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct TopButtonsOverlayView: View {
    
    let buttons: [BotsiLayoutModel.TopButton]
    @EnvironmentObject var actionHandler: PaywallActionHandler
    
    public var body: some View {
        Color.clear
            .overlay(alignment: .topLeading) {
                buttonIfNeeded(for: .left)
            }
            .overlay(alignment: .top) {
                buttonIfNeeded(for: .center)
            }
            .overlay(alignment: .topTrailing) {
                buttonIfNeeded(for: .right)
            }
            .padding(.horizontal, 12)
    }
    
    private func buttonIfNeeded(for align: BotsiAlign) -> AnyView {
        if let button = buttons.first(where: { $0.buttonAlign == align }) {
            return AnyView(topButton(for: button))
        }
        return AnyView(EmptyView())
    }
    
    private func topButton(for button: BotsiLayoutModel.TopButton) -> some View {
        TopButtonView(button: button)
    }
}

@available(iOS 15.0, *)
public struct TopButtonView: View {
    
    let button: BotsiLayoutModel.TopButton
    @EnvironmentObject var actionHandler: PaywallActionHandler
    
    public var body: some View {
        Button(action: {
            guard let actionId = button.actionId else { return }
            actionHandler.handleAction(.action(actionId, customId: button.action))
        }) {
            buttonContent
        }
        .styledContainer(
            fillColor: button.style.fillColor,
            borderColor: button.style.borderColor,
            borderThickness: button.style.borderThickness.toCGFloat(),
            cornerRadius: button.style.radius.toCGFloat()
        )
        .disabled(!button.enabled)
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        switch button.buttonType {
        case .icon:
            Image(systemName: systemIconName(for: button.icon.type))
                .resizable()
                .scaledToFit()
                .frame(width: 8, height: 8)
                .foregroundColor(button.icon.color.toColor().opacity(button.iconOpacity))
                .padding(12)
        case .text:
            BotsiTextBlockView(propertiesProvider: button.text,
                               text: button.text.text,
                               align: .center,
                               opacity: Double(button.text.opacity ?? 100))
            .padding(.vertical, 4)
            .padding(.horizontal, 14)
            .fixedSize(horizontal: true, vertical: false)
        default:
            EmptyView()
        }
    }
    
    private func systemIconName(for type: String) -> String {
        switch type.lowercased() {
        case "close": return "xmark"
        case "back": return "chevron.backward"
        default: return "questionmark"
        }
    }
}
