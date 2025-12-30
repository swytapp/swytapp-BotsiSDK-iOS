//
//  BotsiCardBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiCardBlockView: View {
    
    private let helper: BotsiCardHelper
    
    public init(helper: BotsiCardHelper) {
        self.helper = helper
    }
    
    public var body: some View {
        VStack(spacing: helper.spacing) {
            ForEach(helper.children, id: \.meta.id) { child in
                switch child.content {
                case .text, .image, .button, .list, .timer:
                    BotsiBlockRendererView(block: child)
                        .padding(child.content?.padding)
                default:
                    EmptyView()
                }
            }
        }
        .padding(helper.padding)
        .frame(height: helper.blockHeight, alignment: .top)
        .background(backgroundImageIfNeeded())
        .styledContainer(fillColor: helper.hasBackgroundImage ? nil : helper.fillColor,
                         borderColor: helper.borderColor,
                         borderThickness: helper.borderWidth,
                         cornerRadius: helper.cornerRadius)
        .offset(y: helper.verticalOffset)
    }
}

@available(iOS 15.0, *)
private extension BotsiCardBlockView {
    @ViewBuilder
    func backgroundImageIfNeeded() -> some View {
        if let backgroundImage = helper.backgroundImage {
            BotsiImageBlockView(url: backgroundImage)
        } else {
            Color.clear
        }
    }
}
