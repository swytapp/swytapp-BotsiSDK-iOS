//
//  BotsiTextBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiTextBlockView<T: BotsiPropertiesProvider>: View {
    
    private let textProvider: T
    private let text: String
    private let options: (align: BotsiAlign, maxLines: Int?, onOverflow: BotsiTextOverflow?, opacity: Double, verticalOffset: CGFloat)
    
    init(propertiesProvider: T, 
         text: String,
         align: BotsiAlign = .left,
         maxLines: Int? = nil,
         onOverflow: BotsiTextOverflow? = nil,
         opacity: Double = 100,
         verticalOffset: CGFloat = 0) {
        self.textProvider = propertiesProvider
        self.text = text
        self.options = (align, maxLines, onOverflow, opacity / 100, verticalOffset)
    }
    
    init(model: BotsiTextModel) where T == BotsiTextModel.TextBlock {
        self.textProvider = model.text
        self.text = model.text.text
        self.options = (model.text.align ?? .left, model.maxLinesCount, model.onOverflow, 1, model.verticalOffsetValue)
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
            .offset(y: options.verticalOffset)
            .if(options.onOverflow == .scale) {
                $0.minimumScaleFactor(0.5)
            }
            .frame(alignment: .trailing)
            .multilineTextAlignment(.trailing)
    }
}
