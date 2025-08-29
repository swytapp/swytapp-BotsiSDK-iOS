//
//  BotsiImageBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiImageBlockView: View {
    
    private let model: BotsiImageModel
    private let size: CGSize?
    private let imageModifier: ((Image) -> AnyView)?
    
    public init(model: BotsiImageModel,
                imageModifier: ((Image) -> AnyView)? = nil) {
        self.model = model
        self.size = nil
        self.imageModifier = imageModifier
    }
    
    public init(url: String,
                size: CGSize,
                aspect: BotsiImageAspect = .fit,
                imageModifier: ((Image) -> AnyView)? = nil) {
        self.model = BotsiImageModel(image: url, aspect: aspect)
        self.size = size
        self.imageModifier = imageModifier
    }
    
    public var body: some View {
        let padding = model.padding
        Color.clear
            .overlay (
                AsyncImage(url: URL(string: model.image)) { phase in
                    switch phase {
                    case .success(let image):
                        imageView(from: image)
                    case .empty:
                        ProgressView()
                    case .failure, _:
                        Color.clear
                    }
                }
            )
            .frame(width: size?.width, height: size?.height ?? model.height?.toCGFloat(default: 150))
            .padding(model.padding)
            .clipped()
            .offset(y: model.verticalOffset?.toCGFloat() ?? 0)
    }
    
    @ViewBuilder
    private func imageView(from image: Image) -> some View {
        let resizableImage = image.resizable()
        if let modifier = imageModifier {
            modifier(resizableImage)
                .modifier(AspectRatioModifier(aspect: model.aspect))
        } else {
            resizableImage
                .modifier(AspectRatioModifier(aspect: model.aspect))
        }
    }
}

@available(iOS 15.0, *)
private struct AspectRatioModifier: ViewModifier {
    let aspect: BotsiImageAspect
    
    func body(content: Content) -> some View {
        switch aspect {
        case .fill:
            content.aspectRatio(2.5, contentMode: .fill)
        case .fit:
            content.aspectRatio(contentMode: .fit)
        case .stretch:
            content
        }
    }
}
