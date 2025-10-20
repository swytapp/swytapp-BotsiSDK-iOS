//
//  BotsiHeroImageView.swift
//  Botsi
//
//  Created by Konstantin on 14.07.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiHeroImageView: View {
    
    let model: BotsiHeroImageModel

    public var body: some View {
        switch model.style {
        case .transparent:
            ZStack {
                Color.clear
                    .background(
                        BotsiHeroImage(imageURL: model.backgroundImage)
                            .ignoresSafeArea()
                    )
                Color.clear
                    .backgroundFill(model.fillColor)
            }

        case .overlay:
            BotsiHeroImage(imageURL: model.backgroundImage)

        case .flat:
            BotsiHeroImage(imageURL: model.backgroundImage)
        }
    }
}

@available(iOS 15.0, *)
private struct BotsiHeroImage: View {
    
    let imageURL: String?

    var body: some View {
        if let imageURL, let url = URL(string: imageURL) {
            AsyncImage(url: url, transaction: Transaction(animation: .none)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure(_):
                    Color.gray.opacity(0.2)
                case .empty:
                    Color.gray.opacity(0.2)
                @unknown default:
                    Color.gray.opacity(0.2)
                }
            }
            .drawingGroup()
        } else {
            Color.gray.opacity(0.2)
        }
    }
}
