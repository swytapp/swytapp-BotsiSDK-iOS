//
//  BotsiCardBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiCardBlockView: View {
    
    @StateObject private var vm: BotsiCardViewModel
    
    init(viewModel: BotsiCardViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(vm.children ?? [], id: \.meta.id) { child in
                switch child.content {
                case .text, .image, .button, .list, .timer:
                    BotsiBlockRendererView(block: child) { action in
                        print("KA: \(action)")
                    }
                default:
                    EmptyView()
                }
            }
        }
        .padding(.leading, vm.padding.left)
        .padding(.top, vm.padding.top)
        .padding(.trailing, vm.padding.right)
        .padding(.bottom, vm.padding.bottom)
        .background(vm.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: vm.cornerRadius)
                .stroke(vm.borderColor, lineWidth: vm.borderWidth)
        )
        .cornerRadius(vm.cornerRadius)
    }
}
