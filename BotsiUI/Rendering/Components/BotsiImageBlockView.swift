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
    private let fallbackImage: String?
    
    public init(model: BotsiImageModel,
                fallbackImage: String? = nil,
                imageModifier: ((Image) -> AnyView)? = nil) {
        self.model = model
        self.size = nil
        self.imageModifier = imageModifier
        self.fallbackImage = fallbackImage
    }
    
    public init(url: String,
                size: CGSize? = nil,
                aspect: BotsiImageAspect = .fill,
                fallbackImage: String? = nil,
                imageModifier: ((Image) -> AnyView)? = nil) {
        self.model = BotsiImageModel(image: url, aspect: aspect)
        self.size = size
        self.imageModifier = imageModifier
        self.fallbackImage = fallbackImage
    }
    
    public var body: some View {
        Color.clear
            .overlay (
                AsyncImage(url: URL(string: model.image), transaction: Transaction(animation: .none)) { phase in
                    switch phase {
                    case .success(let image):
                        imageView(from: image)
                    case .empty:
                        imageView(from: Image(systemName: fallbackImage ?? ""))
                    case .failure, _:
                        imageView(from: Image(systemName: fallbackImage ?? ""))
                    }
                }
                .padding(model.padding)
                .drawingGroup(),
                alignment: .top
            )
            .frame(width: size?.width, height: size?.height ?? model.height?.toCGFloat(default: 150), alignment: .top)
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
            content.aspectRatio(contentMode: .fill)
        case .fit:
            content.aspectRatio(contentMode: .fit)
        case .stretch:
            content
        }
    }
}
