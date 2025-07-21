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
        
        let padding = vm.padding
        let margin = vm.margin
        
        HStack {
            if vm.alignment == .trailing {
                Spacer()
            }
            
            buttonContent
                .padding(.leading, padding?.left)
                .padding(.top, padding?.top)
                .padding(.trailing, padding?.right)
                .padding(.bottom, padding?.bottom)
                .backgroundFill(bgColor)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: CGFloat(vm.borderWidth))
                )
            
            if vm.alignment == .leading {
                Spacer()
            }
        }
        .padding(.leading, margin?.left)
        .padding(.top, margin?.top)
        .padding(.trailing, margin?.right)
        .padding(.bottom, margin?.bottom)
        .offset(y: vm.verticalOffset)
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        Button {
            vm.tap()
        } label: {
            VStack(spacing: 0) {
                Text(vm.text?.text ?? "")
                    .font(vm.font)
                    .foregroundColor(vm.textColor)
                    .frame(maxWidth: .infinity)

                if let secondaryText = vm.secondaryText, !secondaryText.text.isEmpty {
                    Text(secondaryText.text)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
#Preview {
    HStack {
//        if vm.alignment == .trailing {
//            Spacer()
//        }
//        
        Button {
            
        } label: {
            VStack(spacing: 0) {
                Text("Continue")
//                    .font(vm.font)
                    .foregroundColor(.yellow)
                    .frame(maxWidth: .infinity)
                
//                if let secondaryText = vm.secondaryText {
//                    Text(secondaryText.text)
//                }
            }
        }
        .frame(height: 40)
        .padding(.leading, 0)
        .padding(.top, 0)
        .padding(.trailing, 0)
        .padding(.bottom, 0)
        .background(.red)
        .cornerRadius(5)
//        .overlay(
//            RoundedRectangle(cornerRadius: 5)
//                .stroke(.black, lineWidth: CGFloat(0))
//        )
        
//        if vm.alignment == .leading {
//            Spacer()
//        }
    }
    .padding(.leading, 0)
    .padding(.top, 0)
    .padding(.trailing, 0)
    .padding(.bottom, 0)
    .offset(y: 0)
}
