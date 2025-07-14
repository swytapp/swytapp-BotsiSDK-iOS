//
//  TopButtonsOverlayView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 23.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct TopButtonsOverlayView: View {
    
    let buttons: [BotsiLayoutModel.TopButton]
    var tap: (BotsiActionType) -> Void
    
    public var body: some View {
        VStack {
            HStack {
                buttonGroup(for: .left)
                Spacer()
                buttonGroup(for: .center)
                Spacer()
                buttonGroup(for: .right)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            Spacer()
        }
        .zIndex(1000)
    }
    
    private func buttonGroup(for align: BotsiAlign) -> some View {
        let filtered = buttons.filter { $0.buttonAlign == align }
        return HStack(spacing: 8) {
            ForEach(filtered) { button in
                TopButtonView(button: button) { action in
                    tap(action)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct TopButtonView: View {
    
    let button: BotsiLayoutModel.TopButton
    var tap: (BotsiActionType) -> Void
    
    var body: some View {
        switch button.buttonType {
        case .icon:
            IconButton()
        case .text:
            TextButton()
        default:
            EmptyView()
        }
    }
    
    private func IconButton() -> some View {
        Button(action: {
            guard let actionId = button.actionId else { return }
            tap(actionId)
        }) {
            Image(systemName: systemIconName(for: button.icon.type))
                .resizable()
                .scaledToFit()
                .frame(width: 8, height: 8)
                .foregroundColor(Color(hex: button.icon.color)
                    .opacity(Double(button.iconOpacity)))
                .padding(12)
        }
        .background(
            Circle()
                .fill(Color(hex: button.style.color)
                    .opacity(Double(button.styleOpacity)))
                .frame(width: 25)
        )
        .overlay(
            Circle()
                .stroke(
                    Color(hex: button.style.borderColor)
                        .opacity(Double(button.style.borderOpacity)),
                    lineWidth: button.style.borderThickness.toCGFloat()
                )
        )
        .disabled(!button.enabled)
    }
    
    private func TextButton() -> some View {
        Button(action: {
            guard let actionId = button.actionId else { return }
            tap(actionId)
        }) {
            Text(button.text.text ?? "")
                .font(.system(size: button.text.size.toCGFloat()))
                .foregroundColor(Color.black
                    .opacity(Double(button.text.opacity)))
                .padding(.vertical, 2)
                .padding(.horizontal, 10)
        }
        .background(fillBackground(for: button.style.fillColor, opacity: Double(button.styleOpacity)))
        .overlay(
            Capsule()
                .stroke(
                    Color(hex: button.style.borderColor)
                        .opacity(Double(button.style.borderOpacity)),
                    lineWidth: button.style.borderThickness.toCGFloat()
                )
        )
        .disabled(!button.enabled)
    }
    
    private func systemIconName(for type: String) -> String {
        switch type.lowercased() {
        case "close": return "xmark"
        case "back": return "chevron.backward"
        default: return "questionmark"
        }
    }
    
    @ViewBuilder
    private func fillBackground(for fillColor: BotsiFillColor?, opacity: Double) -> some View {
        switch fillColor {
        case .solid(let color):
            Circle()
                .fill(color)
                .opacity(opacity)
        case .gradient(let gradient):
            Circle()
                .fill(gradient)
                .opacity(opacity)
        case .none:
            EmptyView()
        }
    }
}

#Preview {
    Button(action: {
        
    }) {
        Image(systemName: "xmark")
            .resizable()
            .scaledToFit()
            .frame(width: 12, height: 12)
            .foregroundColor(Color.red
                .opacity(Double(100)))
            .padding(12)
    }
    .frame(width: 45, height: 45)
    .background(
        Circle()
            .fill(Color.black
                .opacity(Double(0.1)))
            .frame(width: 30)
    )
    .overlay(
        Circle()
            .stroke(
                Color.red
                    .opacity(Double(100)),
                lineWidth: CGFloat(0)
            )
    )
}

