//
//  BotsiHelpers.swift
//
//
//  Created by Aleksey Goncharov on 12.06.2024.
//

// TODO: BotsiHelpers.swift не хорошее название файла ,
// в данном файле есть extension для Collection+SafeSubscript
// и объявление  struct BotsiIdentifiablePlaceholder:
// стоит разбить соотвественно на два файла

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
