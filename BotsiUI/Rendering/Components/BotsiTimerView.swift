//
//  BotsiTimerView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiTimerBlockView: View {
    
    let model: BotsiTimerModel
    @StateObject private var viewModel: BotsiTimerViewModel
    
    init(model: BotsiTimerModel) {
        self.model = model
        _viewModel = StateObject(wrappedValue: BotsiTimerViewModel(model: model))
    }
    
    var body: some View {
        VStack {
            Text(viewModel.fullText)
                .foregroundFill(model.style.color)
                .font(.system(size: model.style.size?.toCGFloat() ?? 14))
                .lineLimit(1)
                .minimumScaleFactor(0.01)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity, alignment: model.style.align?.alignment ?? .center)
        .padding(.leading, model.padding.left)
        .padding(.top, model.padding.top)
        .padding(.trailing, model.padding.right)
        .padding(.bottom, model.padding.bottom)
        .offset(y: model.verticalOffset.toCGFloat())
    }
}
