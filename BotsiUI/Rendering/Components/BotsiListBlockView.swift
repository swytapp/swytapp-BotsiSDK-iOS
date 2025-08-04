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
        VStack(alignment: .leading, spacing: itemSpacing) {
            ForEach(Array(items.enumerated()), id: \.1.safeID) { index, item in
                BotsiListItemView(
                    item: item,
                    connectorThickness: item.thickness,
                    connectorColor: item.connectorColor,
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var itemSpacing: CGFloat {
        guard let string = model.itemSpacing, let value = Double(string) else { return 8 }
        return value
    }
}
