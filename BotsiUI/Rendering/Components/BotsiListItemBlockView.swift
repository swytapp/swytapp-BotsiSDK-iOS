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

    public var body: some View {
        HStack(alignment: .center, spacing: 10) {
            iconView
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 0) {
                if let title = item.titleText ?? item.titleTextFallback {
                    Text(title)
                        .foregroundColor(Color(hex: item.titleTextStyle.color))
                        .font(.system(size: 12))
                }

                if let caption = item.captionText ?? item.captionTextFallback {
                    Text(caption)
                        .foregroundColor(Color(hex: item.captionTextStyle.color))
                        .font(.system(size: 10))
                }
            }


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
            .foregroundColor(Color(hex: item.connectorColor))
            .opacity(Double(item.connectorOpacity ?? 100) / 100)
    }
}
