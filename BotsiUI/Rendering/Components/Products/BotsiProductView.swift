//
//  BotsiProductView.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 16.09.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiProductView: View {
    @StateObject private var viewModel: BotsiProductViewModel
    @EnvironmentObject private var actionHandler: PaywallActionHandler
    
    init(viewModel: BotsiProductViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        Group {
            if viewModel.alignment == .column {
                columnLayout
            } else {
                rowLayout
            }
        }
        .padding(viewModel.layout.padding)
        .styledContainer(fillColor: viewModel.style(actionHandler: actionHandler).fillColor,
                         borderColor: viewModel.style(actionHandler: actionHandler).borderColor,
                         borderThickness: viewModel.style(actionHandler: actionHandler).borderWidth,
                         cornerRadius: viewModel.style(actionHandler: actionHandler).radius)
        .overlay(alignment: .top) {
            if viewModel.product.isBadge {
                badgeView
            }
        }
        .onTapGesture {
            guard let productId = Int(viewModel.product.productId ?? "") else {
                return
            }
            actionHandler.handleAction(.didSelectProduct(productId))
        }
    }
}

@available(iOS 15.0, *)
private extension BotsiProductView {
    
    var badgeView: some View {
        let badge = viewModel.product.badge
        return BotsiTextBlockView(
            propertiesProvider: badge,
            text: badge.badgeText,
            align: .center,
        )
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .fixedSize()
        .background(
            RoundedRectangle(cornerRadius: badge.badgeRadius.toCGFloat())
                .fill(badge.badgeColor.toColor())
        )
        .offset(y: (badge.size?.toCGFloat() ?? 0) * -0.7 )
    }
    
    var columnLayout: some View {
        HStack {
            VStack(spacing: 6) {
                textViewGroup(viewModel.texts(actionHandler: actionHandler).filter { $0.0 == 0 || $0.0 == 1 })
            }
            VStack(spacing: 6) {
                textViewGroup(viewModel.texts(actionHandler: actionHandler).filter { $0.0 == 2 || $0.0 == 3 })
            }
        }
    }
    
    var rowLayout: some View {
        VStack(spacing: 6) {
            ForEach(viewModel.texts(actionHandler: actionHandler), id: \.0) { index, textStyle, text in
                if !text.isEmpty {
                    BotsiTextBlockView(propertiesProvider: textStyle,
                                       text: text,
                                       align: viewModel.textAlignment(for: index),
                                       height: .infinity)
                    .frame(maxHeight: .infinity)
                }
            }
        }
    }
    
    @ViewBuilder
    func textViewGroup(_ texts: [(Int, BotsiTextStyleModel, String)]) -> some View {
        ForEach(texts, id: \.0) { index, textStyle, text in
            BotsiTextBlockView(propertiesProvider: textStyle,
                               text: text,
                               align: viewModel.textAlignment(for: index),
                               height: .infinity)
            .frame(maxHeight: .infinity)
        }
    }
}
