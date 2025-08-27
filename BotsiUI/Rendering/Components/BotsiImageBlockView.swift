//
//  BotsiImageBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiImageBlockView: View {
    
    let model: BotsiImageModel
    
    var body: some View {
        let padding = model.padding
        Color.clear
            .overlay (
                AsyncImage(url: URL(string: model.image)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .modifier(AspectRatioModifier(aspect: model.aspect))
                    case .failure(_):
                        Color.clear
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            )
            .frame(height: model.height?.toCGFloat(default: 150))
            .padding(padding)
            .clipped()
            .offset(y: model.verticalOffset?.toCGFloat() ?? 0)
    }
}

private struct AspectRatioModifier: ViewModifier {
    let aspect: String
    
    func body(content: Content) -> some View {
        switch aspect.lowercased() {
        case "fill":
            content
                .aspectRatio(2.5, contentMode: .fill)
        case "fit":
            content
                .aspectRatio(contentMode: .fit)
        default:
            content
        }
    }
}
