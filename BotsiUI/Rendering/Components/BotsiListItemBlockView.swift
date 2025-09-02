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
    
    public var body: some View {
        HStack(alignment: iconAlignment, spacing: 10) {
            VStack(spacing: 0) {
                if item.icon != nil && item.icon != "" {
                    iconView
                    connectorViewIfNeeded()
                } else {
                    connectorViewIfNeeded()
                }
            }
            
            VStack(spacing: textSpacing) {
                titleView
                captionView
            }
        }
    }
}

// MARK: - Left VStack
@available(iOS 15.0, *)
private extension BotsiListItemView {
    @ViewBuilder
    var iconView: some View {
        if let iconURL = item.icon {
            BotsiImageBlockView(url: iconURL,
                                size: imageSize,
                                aspect: .fit)
            .padding(-5)
        }
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
