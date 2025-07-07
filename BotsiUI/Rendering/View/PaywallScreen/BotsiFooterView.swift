//
//  BotsiFooterView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 20.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiFooterView: View {
    
    @ObservedObject var vm: BotsiFooterViewModel

    public var body: some View {
        VStack(spacing: 8) {
//            Text(vm.model.title)
//                .font(.caption)
//                .foregroundStyle(.secondary)

//            ForEach(vm.childVMs, id: \.id) { block in
//                BotsiBlockRenderer.render(block)
//            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}
