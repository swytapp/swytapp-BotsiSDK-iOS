//
//  BotsiFooterBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiFooterBlockView: View {
    
    @StateObject private var vm: BotsiFooterViewModel
    
    public init(viewModel: BotsiFooterViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: vm.spacing) {
            ForEach(vm.childrens ?? [], id: \.meta.id) { child in
                BotsiBlockRendererView(block: child) { action in
                    print("KA: \(action)")
                }
            }
        }
        .backgroundFill(vm.fillColor)
    }
}
