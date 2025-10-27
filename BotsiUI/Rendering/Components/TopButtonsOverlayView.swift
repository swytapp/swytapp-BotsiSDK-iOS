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
    @EnvironmentObject var productViewModel: BotsiProductViewModel
    @State private var isVisible = false
    
    public var body: some View {
        Button(action: {
            switch button.action {
            case .restore:
                productViewModel.restorePurchases()
            default:
                actionHandler.handleAction(button.action, customId: button.actionId)
            }
        }) {
            buttonContent
        }
        .styledContainer(
            fillColor: button.style.fillColor,
            borderColor: button.style.borderColor,
            borderThickness: button.style.borderThickness.toCGFloat(),
            cornerRadius: button.style.radius.toCGFloat()
        )
        .disabled(!button.enabled || !isVisible)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            let delayInSeconds = Double(button.delay)
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible = true
                }
            }
        }
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        switch button.buttonType {
        case .icon:
            Image(systemName: button.icon.type.systemIconName)
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
                .foregroundColor(button.icon.color.toColor().opacity(button.iconOpacity))
                .padding(12)
        case .text:
            BotsiTextBlockView(propertiesProvider: button.text,
                               text: button.text.text ?? "",
                               align: .center,
                               opacity: Double(button.text.opacity ?? 100))
            .padding(.vertical, 4)
            .padding(.horizontal, 14)
            .fixedSize(horizontal: true, vertical: false)
        default:
            EmptyView()
        }
    }
}
