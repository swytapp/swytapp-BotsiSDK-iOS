//
//  BotsiCaoruselBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiCarouselBlockView: View {
    
    let block: BotsiPaywallBlock

    var body: some View {
        TabView {
            ForEach(block.children ?? [], id: \.meta.id) { block in
                BotsiBlockRendererView(block: block)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 360) 
    }
}
