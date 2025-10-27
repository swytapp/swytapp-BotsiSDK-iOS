//
//  BotsiListItemBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiListItemView: View {
    
    let item: BotsiListItemModel
    let imageSize: CGSize
    let textSpacing: CGFloat
    let iconAlignment: VerticalAlignment
    let defaultIcon: BotsiListModel.DefaultIcon
    let defaultIconColor: BotsiFillColor?
    
    public var body: some View {
        HStack(spacing: 10) {
            ZStack {
                connectorViewIfNeeded()
                iconVStack
            }
            
            VStack(spacing: textSpacing) {
                titleView
                captionView
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Left VStack
@available(iOS 15.0, *)
private extension BotsiListItemView {
    @ViewBuilder
    var iconVStack: some View {
        VStack(spacing: 0) {
            if iconAlignment == .bottom || iconAlignment == .center {
                Spacer()
            }
            
            iconView
            
            if iconAlignment == .top || iconAlignment == .center {
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var iconView: some View {
        BotsiImageBlockView(url: item.icon ?? "",
                            size: imageSize,
                            aspect: .fit,
                            fallbackImage: defaultIcon.icon,
                            imageModifier: { image -> AnyView in
            if item.icon == nil || item.icon == "" {
                return AnyView(image
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(defaultIconColor?.toColor() ?? .white)
                )
            } else {
                return AnyView(image)
            }
        })
    }
}

// MARK: - Right VStack
@available(iOS 15.0, *)
private extension BotsiListItemView {
    
    @ViewBuilder
    func connectorViewIfNeeded() -> some View {
        if item.thickness > 0 {
            Divider()
                .frame(width: item.thickness)
                .frame(maxHeight: .infinity)
                .backgroundFill(item.connectorColor)
        }
    }
    
    @ViewBuilder
    var titleView: some View {
        if let titleProperties = item.titleTextStyle,
           let title = item.titleText ?? item.titleTextFallback {
            BotsiTextBlockView(
                propertiesProvider: titleProperties,
                text: title,
            )
        }
    }
    
    @ViewBuilder
    var captionView: some View {
        if let captionProperties = item.captionTextStyle,
           let caption = item.captionText ?? item.captionTextFallback {
            BotsiTextBlockView(
                propertiesProvider: captionProperties,
                text: caption,
            )
        }
    }
}

