//
//  BotsiLinksBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiLinksBlockView: View {
    
    @StateObject private var vm: BotsiLinksViewModel
    
    init(viewModel: BotsiLinksViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Text("Links")
    }
}
