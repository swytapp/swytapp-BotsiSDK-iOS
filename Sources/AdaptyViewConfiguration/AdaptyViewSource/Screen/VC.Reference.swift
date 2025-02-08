//
//  VC.Reference.swift
//  AdqptyUI
//
//  Created by Aleksei Valiano on 06.06.2024
//
//

import Foundation

extension BotsiViewSource.Localizer {
    func reference(_ id: String) throws -> BotsiViewConfiguration.Element {
        guard !self.elementIds.contains(id) else {
            throw BotsiLocalizerError.referenceCycle(id)
        }
        guard let value = source.referencedElemnts[id] else {
            throw BotsiLocalizerError.unknownReference(id)
        }
        elementIds.insert(id)
        let result: BotsiViewConfiguration.Element
        do {
            result = try element(value)
            elementIds.remove(id)
        } catch {
            elementIds.remove(id)
            throw error
        }
        return result
    }
}

extension BotsiViewSource.Screen {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        [content, footer, overlay].compactMap { $0 }.flatMap { $0.referencedElemnts }
    }
}

private extension BotsiViewSource.Button {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        [normalState, selectedState].compactMap { $0 }.flatMap { $0.referencedElemnts }
    }
}

private extension BotsiViewSource.Element {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        switch self {
        case .reference: []
        case let .stack(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .text(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .image(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .video(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .button(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .box(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .row(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .column(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .section(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .toggle(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .timer(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .pager(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .unknown(_, properties):
            properties?.referencedElemnts(self) ?? []
        }
    }
}

private extension BotsiViewSource.Element.Properties {
    func referencedElemnts(_ element: BotsiViewSource.Element) -> [(String, BotsiViewSource.Element)] {
        guard let elementId else { return [] }
        return [(elementId, element)]
    }
}

private extension BotsiViewSource.Box {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        content?.referencedElemnts ?? []
    }
}

private extension BotsiViewSource.Stack {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        items.flatMap { $0.referencedElemnts }
    }
}

private extension BotsiViewSource.StackItem {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        switch self {
        case .space:
            []
        case let .element(value):
            value.referencedElemnts
        }
    }
}

private extension BotsiViewSource.Section {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        content.flatMap { $0.referencedElemnts }
    }
}

private extension BotsiViewSource.Pager {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        content.flatMap { $0.referencedElemnts }
    }
}

private extension BotsiViewSource.Row {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        items.flatMap { $0.referencedElemnts }
    }
}

private extension BotsiViewSource.Column {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        items.flatMap { $0.referencedElemnts }
    }
}

private extension BotsiViewSource.GridItem {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        content.referencedElemnts
    }
}

private extension BotsiViewSource.Text {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        []
    }
}

private extension BotsiViewSource.Image {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        []
    }
}

private extension BotsiViewSource.VideoPlayer {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        []
    }
}

private extension BotsiViewSource.Toggle {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        []
    }
}

private extension BotsiViewSource.Timer {
    var referencedElemnts: [(String, BotsiViewSource.Element)] {
        []
    }
}
