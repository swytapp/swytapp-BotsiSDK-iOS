//
//  BotsiUIElementView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Botsi
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func paddingIfNeeded(_ insets: EdgeInsets?) -> some View {
        if let insets {
            padding(insets)
        } else {
            self
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Element {
    var properties: VC.Element.Properties? {
        switch self {
        case .space:
            return nil
        case let .box(_, properties), let .stack(_, properties),
             let .text(_, properties), let .image(_, properties),
             let .button(_, properties), let .row(_, properties),
             let .column(_, properties), let .section(_, properties),
             let .toggle(_, properties), let .timer(_, properties),
             let .pager(_, properties), let .unknown(_, properties),
             let .video(_, properties):
            return properties
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct BotsiUIElementWithoutPropertiesView: View {
    private var element: VC.Element

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    init(
        _ element: VC.Element
    ) {
        self.element = element
    }

    var body: some View {
        switch element {
        case let .space(count):
            if count > 0 {
                ForEach(0 ..< count, id: \.self) { _ in
                    Spacer()
                }
            }
        case let .box(box, _):
            elementOrEmpty(box.content)
                .fixedFrame(box: box)
                .rangedFrame(box: box)
        case let .stack(stack, _):
            BotsiUIStackView(stack)
        case let .text(text, _):
            BotsiUITextView(text)
        case let .image(image, _):
            BotsiUIImageView(image)
        case let .video(video, _):
            BotsiUIVideoView(video: video, colorScheme: colorScheme)
        case let .button(button, _):
            BotsiUIButtonView(button)
        case let .row(row, _):
            BotsiUIRowView(row)
        case let .column(column, _):
            BotsiUIColumnView(column)
        case let .section(section, _):
            BotsiUISectionView(section)
        case let .toggle(toggle, _):
            BotsiUIToggleView(toggle)
        case let .timer(timer, _):
            BotsiUITimerView(timer)
        case let .pager(pager, _):
            BotsiUIPagerView(pager)
        case let .unknown(value, _):
            BotsiUIUnknownElementView(value: value)
        }
    }

    @ViewBuilder
    private func elementOrEmpty(_ content: VC.Element?) -> some View {
        if let content {
            BotsiUIElementView(content)
        } else {
            Color.clear
                .frame(idealWidth: 0, idealHeight: 0)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package struct BotsiUIElementView: View {
    @EnvironmentObject private var eventsHandler: BotsiEventsHandler
    
    private var element: VC.Element
    private var additionalPadding: EdgeInsets?
    private var drawDecoratorBackground: Bool

    package init(
        _ element: VC.Element,
        additionalPadding: EdgeInsets? = nil,
        drawDecoratorBackground: Bool = true
    ) {
        self.element = element
        self.additionalPadding = additionalPadding
        self.drawDecoratorBackground = drawDecoratorBackground
    }

    package var body: some View {
        let properties = element.properties
        let resolvedVisibility = switch eventsHandler.presentationState {
        case .initial: properties?.visibility ?? true
        default: true
        }

        BotsiUIElementWithoutPropertiesView(element)
            .paddingIfNeeded(additionalPadding)
            .applyingProperties(properties, includeBackground: drawDecoratorBackground)
            .transitionIn(
                properties?.transitionIn,
                visibility: resolvedVisibility
            )
            .modifier(DebugOverlayModifier())
    }
}

#endif
