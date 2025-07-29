//
//  BotsiProductsToggleViewModel.swift
//  Botsi
//
//  Created by Konstantin on 29.07.2025.
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
