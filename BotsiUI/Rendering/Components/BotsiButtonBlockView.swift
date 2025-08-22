//
//  BotsiButtonBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiButtonBlockView: View {
    
    @StateObject private var vm: BotsiButtonViewModel
    
    init(viewModel: BotsiButtonViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        let bgColor = vm.fillColor
        let borderColor = vm.borderColor
        let cornerRadius = vm.cornerRadius
        let padding = vm.model.contentLayout?.padding
        
        HStack {
            
            buttonContent
                .padding(padding)
                .backgroundFill(bgColor)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: CGFloat(vm.borderWidth))
                )
        }
        .offset(y: vm.verticalOffset)
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        Button {
            vm.tap()
        } label: {
            VStack(spacing: 0) {
                if let text = vm.model.text {
                    BotsiTextBlockView(propertiesProvider: text,
                                       text: text.text,
                                       align: vm.align)
                    .frame(maxWidth: .infinity, alignment: vm.model.contentLayout?.align?.alignments.frame ?? .center)
                }
                
                if let secondaryText = vm.model.secondaryText, !secondaryText.text.isEmpty {
                    BotsiTextBlockView(propertiesProvider: secondaryText,
                                       text: secondaryText.text,
                                       align: vm.align)
                    .frame(maxWidth: .infinity, alignment: vm.model.contentLayout?.align?.alignments.frame ?? .center)
                }
            }
            
        }
    }
}
