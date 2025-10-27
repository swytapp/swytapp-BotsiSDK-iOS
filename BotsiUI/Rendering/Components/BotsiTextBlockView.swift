//
//  BotsiTextBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiTextBlockView<T: BotsiTextPropertiesProvider>: View {
    
    private let textProvider: T?
    private let text: String
    private let options: (align: BotsiAlign, maxLines: Int?, onOverflow: BotsiTextOverflow?, opacity: Double, verticalOffset: CGFloat, height: CGFloat?)
    
    init(propertiesProvider: T?,
         text: String,
         align: BotsiAlign = .left,
         maxLines: Int? = nil,
         onOverflow: BotsiTextOverflow? = nil,
         opacity: Double = 100,
         verticalOffset: CGFloat = 0,
         height: CGFloat? = nil) {
        self.textProvider = propertiesProvider
        self.text = text
        self.options = (align, maxLines, onOverflow, opacity / 100, verticalOffset, height)
    }
    
    init(model: BotsiTextModel) where T == BotsiTextModel.TextBlock {
        self.textProvider = model.text
        self.text = model.text.text
        self.options = (model.text.align ?? .left, model.maxLinesCount, model.onOverflow, 1, model.verticalOffsetValue, nil)
    }
    
    var body: some View {
        Text(text)
            .font(.customFont(
                ofSize: textProvider?.textSize ?? 14,
                name: textProvider?.customFont?.name ?? textProvider?.font?.name ?? "System",
                weight: textProvider?.font?.fontWeight ?? 400,
                italic: textProvider?.font?.isItalic ?? false
            ))
            .foregroundFill(textProvider?.color ?? .solid(.white))
            .opacity(options.opacity)
            .lineLimit(options.maxLines)
            .offset(y: options.verticalOffset)
            .if(options.onOverflow == .scale) {
                $0.minimumScaleFactor(0.3)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, maxHeight: options.height, alignment: options.align.alignments.frame)
            .multilineTextAlignment(options.align.alignments.text)
    }
}
