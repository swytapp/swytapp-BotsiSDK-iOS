//
//  BotsiTextBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiTextBlockView<T: BotsiTextBlockProvider>: View {
    
    private let textProvider: T
    private let text: String
    private let options: (margin: BotsiEdge, align: BotsiAlign, maxLines: Int?, onOverflow: BotsiTextOverflow?, opacity: Double, verticalOffset: CGFloat)
    
    init(textProvider: T, 
         text: String,
         margin: BotsiEdge = .defaultEdge,
         align: BotsiAlign = .left,
         maxLines: Int? = nil,
         onOverflow: BotsiTextOverflow? = nil,
         opacity: Double = 100,
         verticalOffset: CGFloat = 0) {
        self.textProvider = textProvider
        self.text = text
        self.options = (margin, align, maxLines, onOverflow, opacity / 100, verticalOffset)
    }
    
    init(model: BotsiTextModel) where T == BotsiTextModel.TextBlock {
        self.textProvider = model.text
        self.text = model.text.text
        self.options = (model.margin, model.text.align ?? .left, model.maxLinesCount, model.onOverflow, 1, model.verticalOffsetValue)
    }
    
    var body: some View {
        Text(text)
            .font(.customFont(
                ofSize: textProvider.textSize,
                name: textProvider.font.name,
                weight: textProvider.font.fontWeight,
                italic: textProvider.font.isItalic
            ))
            .foregroundFill(textProvider.color)
            .opacity(options.opacity)
            .lineLimit(options.maxLines)
            .padding(.leading, options.margin.left)
            .padding(.top, options.margin.top)
            .padding(.trailing, options.margin.right)
            .padding(.bottom, options.margin.bottom)
            .offset(y: options.verticalOffset)
            .if(options.onOverflow == .scale) {
                $0.minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, alignment: options.align.alignments.frame)
            .multilineTextAlignment(options.align.alignments.text)
    }
}
