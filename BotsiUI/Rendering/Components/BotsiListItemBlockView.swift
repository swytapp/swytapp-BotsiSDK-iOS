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
    let connectorThickness: CGFloat
    let connectorColor: BotsiFillColor?

    public var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 10) {
                ZStack {
                    if connectorThickness > 0 {
                        Color.clear
                            .frame(width: connectorThickness)
                            .frame(maxHeight: .infinity)
                            .backgroundFill(connectorColor)
                            .offset(y: geometry.size.height / 2)
                    }
                    
                    iconView
                        .frame(width: 30, height: 30)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    if let title = item.titleText ?? item.titleTextFallback {
                        Text(title)
                            .foregroundFill(item.titleTextStyle?.color)
                            .font(.system(size: 12))
                    }
                    
                    if let caption = item.captionText ?? item.captionTextFallback {
                        Text(caption)
                            .foregroundFill(item.captionTextStyle?.color)
                            .font(.system(size: 10))
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var iconView: some View {
        if let icon = item.icon, let url = URL(string: icon), icon.lowercased().hasPrefix("http") {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    fallbackIcon
                @unknown default:
                    fallbackIcon
                }
            }
        } else {
            fallbackIcon
        }
    }

    private var fallbackIcon: some View {
        Image(systemName: "checkmark.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
