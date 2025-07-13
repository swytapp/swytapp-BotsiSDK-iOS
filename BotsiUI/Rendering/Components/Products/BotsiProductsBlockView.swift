//
//  BotsiProductsBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
public final class BotsiProductsToggleViewModel: ObservableObject {
    // MARK: - Input models
    public let contentModel: BotsiProductsModel
    public var toggleControlModel: BotsiToggleControlModel
    public let toggleOnModel: BotsiToggleOnModel
    public let toggleOffModel: BotsiToggleOffModel
    public let toggleChildren: [BotsiPaywallBlock]
    
    // MARK: - Published Properties
    @Published public var isToggleOn: Bool
    @Published public var selectedProductId: String?
    
    // MARK: - Init
    public init(
        contentModel: BotsiProductsModel,
        toggleControlModel: BotsiToggleControlModel,
        toggleOnModel: BotsiToggleOnModel,
        toggleOffModel: BotsiToggleOffModel,
        toggleChildren: [BotsiPaywallBlock]
    ) {
        self.contentModel = contentModel
        self.toggleControlModel = toggleControlModel
        self.toggleOnModel = toggleOnModel
        self.toggleOffModel = toggleOffModel
        self.toggleChildren = toggleChildren
        
        self.isToggleOn = toggleControlModel.toggleState.lowercased() == "on"
        self.selectedProductId = contentModel.selectedProduct
    }
    
    // MARK: - Actions
    public func toggleChanged(to newValue: Bool) {
        isToggleOn = newValue
    }
    
    public func selectProduct(with id: String) {
        selectedProductId = id
    }
    
    // MARK: - Helpers
    public var activeChildren: [BotsiPaywallBlock] {
        isToggleOn ? [] : toggleChildren
    }
}

@available(iOS 15.0, *)
struct BotsiProductsToggleView: View {
    
    @ObservedObject var viewModel: BotsiProductsToggleViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            toggleControlView
            contentForCurrentToggleState
        }
        .padding()
    }
    
    private var toggleControlView: some View {
        Toggle(isOn: $viewModel.isToggleOn) {
            Text(viewModel.toggleControlModel.activeState.text ?? "")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
    }
    
    @ViewBuilder
    private var contentForCurrentToggleState: some View {
        if !viewModel.isToggleOn {
            toggleOffContentView
        }
    }
    
    private var toggleOffContentView: some View {
        VStack(spacing: viewModel.toggleOffModel.contentLayout.spacing?.toCGFloat()) {
            if !viewModel.toggleChildren.isEmpty {
                ForEach(viewModel.toggleChildren, id: \.meta.id) { block in
                    if case .productItem(let model) = block.content {
                        let isSelected = viewModel.selectedProductId == block.meta.id
                        productItemView(model, meta: block.meta, isSelected: isSelected)
                    }
                }
            } else {
                Text("No Products Available")
            }
        }
    }
    
    private func productItemView(_ product: BotsiProductItemModel, meta: BotsiBlockMeta, isSelected: Bool) -> some View {
        ZStack(alignment: .top) {
            VStack(alignment: viewModel.toggleOffModel.contentLayout.align.horizontalAlignment, spacing: 4) {
                Text(product.defaultText.text1)
                    .font(.system(size: product.defaultState?.text1.size.toCGFloat() ?? 12))
                    .foregroundStyle(Color(hex: product.defaultState?.text1.color ?? "#ffffff")
                        .opacity(Double(product.defaultState?.text1.opacity ?? 0)))
                if !product.defaultText.text2.isEmpty {
                    Text(product.defaultText.text2)
                        .font(.system(size: product.defaultState?.text2.size.toCGFloat() ?? 12))
                        .foregroundStyle(Color(hex: product.defaultState?.text2.color ?? "#ffffff")
                            .opacity(Double(product.defaultState?.text2.opacity ?? 0)))
                }
                if !product.defaultText.text3.isEmpty {
                    Text(product.defaultText.text3)
                        .font(.system(size: product.defaultState?.text3.size.toCGFloat() ?? 12))
                        .foregroundStyle(Color(hex: product.defaultState?.text3.color ?? "#ffffff")
                            .opacity(Double(product.defaultState?.text3.opacity ?? 0)))
                }
                if !product.defaultText.text4.isEmpty {
                    Text(product.defaultText.text4)
                        .font(.system(size: product.defaultState?.text4.size.toCGFloat() ?? 12))
                        .foregroundStyle(Color(hex: product.defaultState?.text4.color ?? "#ffffff")
                            .opacity(Double(product.defaultState?.text4.opacity ?? 0)))
                }
            }
            .frame(maxWidth: .infinity, alignment: viewModel.toggleOffModel.contentLayout.align.alignment)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .onTapGesture {
                viewModel.selectProduct(with: meta.id)
            }
            
            if product.isBadge {
                let badge = product.badge
                Text(badge.badgeText)
                    .font(.system(size: badge.badgeTextSize.toCGFloat()))
                    .foregroundStyle(Color(hex: badge.badgeTextColor))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: badge.badgeColor))
                    .cornerRadius(12)
                    .offset(y: -12)
            }
        }
    }
}
