//
//  BotsiListBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiListBlockView: View {
    
    private let model: BotsiListModel
    private let items: [BotsiListItemModel]

    public init?(block: BotsiPaywallBlock) {
        guard case let .list(listModel) = block.content else {
            return nil
        }
        self.model = listModel

        self.items = block.children?.compactMap {
            if case let .listItem(itemModel) = $0.content {
                return itemModel
            } else {
                return nil
            }
        } ?? []
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: model.itemSpacing) {
            ForEach(Array(items.enumerated()), id: \.1.safeID) { _, item in
                BotsiListItemView(item: item,
                                  imageSize: model.imageSize,
                                  textSpacing: model.textSpacing,
                                  iconAlignment: model.iconPlacement.alignments.vertical)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
