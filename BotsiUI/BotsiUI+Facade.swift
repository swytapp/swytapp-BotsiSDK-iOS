//
//  BotsiUI+Facade.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public enum BotsiUI {

    @MainActor
    public static func makePaywall(json data: Data,
                                   id: String = UUID().uuidString,
                                   delegate: BotsiPaywallDelegate? = nil) throws -> some View {

        let structure = try BotsiPaywallParser.parseStructure(from: data)
        
        guard let content = structure.content, let layout = structure.layout else {
            throw BotsiUIError.contentParsingError
        }

        let model = BotsiPaywallModel(id: id,
                                      layout: layout,
                                      content: content,
                                      footer: structure.footer,
                                      hero: structure.heroImage)

        let rootVM = BotsiPaywallViewModel(model: model, delegate: delegate)

        return BotsiPaywallScreen(viewModel: rootVM)
    }
}
