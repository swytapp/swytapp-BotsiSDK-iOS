//
//  BotsiTextBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiTextBlockView: View {
    
    private var model: BotsiTextModel
    
    init(model: BotsiTextModel) {
        self.model = model
    }
    
    var body: some View {
        let margin = model.margin
        Text(model.text.text)
            .font(.custom(model.text.font.name, size: model.textSize))
            .foregroundColor(Color(hex: model.text.color).opacity(model.textOpacity))
//            .multilineTextAlignment(model.textAlignment)
            .lineLimit(model.maxLinesCount)
            .padding(.leading, margin?.left)
            .padding(.top, margin?.top)
            .padding(.trailing, margin?.right)
            .padding(.bottom, margin?.bottom)
            .offset(y: model.verticalOffsetValue)
            .if(model.onOverflow == .scale) {
                $0.minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, alignment: model.text.align.alignment)
    }
}
