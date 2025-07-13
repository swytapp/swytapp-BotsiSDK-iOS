////
////  BotsiProductsBlockViewModel.swift
////  Botsi
////
////  Created by Kostiantyn Antoniuk on 18.06.2025.
////
//
//import SwiftUI
//
//@available(iOS 15.0, *)
//public final class BotsiProductsViewModel: ObservableObject {
//    
//    public let content: BotsiProductsBlockModel?
//    public let toggleControl: BotsiToggleControlModel?
//    public let toggleOnItems: [BotsiPaywallBlock]
//    public let toggleOffItems: [BotsiPaywallBlock]
//
//    @Published public var isToggleOn: Bool
//
//    public init(block: BotsiPaywallBlock) {
//        self.content = block.content as? BotsiProductsBlockModel
//        self.toggleControl = block.children?.first(where: { $0.meta.type == .toggleControl })?.content as? BotsiToggleControlModel
//
//        let toggleOnItems = block.children.first(where: { $0.meta.type == .toggleOn })?.children ?? []
//        let toggleOffItems = block.children.first(where: { $0.meta.type == .toggleOff })?.children ?? []
//
//        self.isToggleOn = toggleControl?.state == "selected"
//    }
//}
//
//@available(iOS 15.0, *)
//public struct BotsiProductsBlockView: View {
//    
//    @StateObject var vm: BotsiProductsViewModel
//
//    public init(block: BotsiPaywallBlock) {
//        _vm = StateObject(wrappedValue: BotsiProductsViewModel(block: block))
//    }
//
//    public var body: some View {
//        VStack(spacing: 12) {
//            if let toggleControl = vm.toggleControl {
//                BotsiToggleControlView(model: toggleControl, isOn: $vm.isToggleOn)
//            }
//            if vm.isToggleOn {
//                ForEach(vm.toggleOnItems, id: \.meta.id) { block in
//                    BotsiBlockRendererView(block: block, onAction: { _ in })
//                }
//            } else {
//                ForEach(vm.toggleOffItems, id: \.meta.id) { block in
//                    BotsiBlockRendererView(block: block, onAction: { _ in })
//                }
//            }
//        }
//        .padding()
//    }
//}
//
//@available(iOS 15.0, *)
//public struct BotsiToggleControlView: View {
//    
//    public let model: BotsiToggleControlModel
//    @Binding public var isOn: Bool
//
//    public var body: some View {
//        Toggle(isOn: $isOn) {
//            VStack(alignment: .leading) {
//                Text(isOn ? model.activeState.text ?? "On" : model.inactiveState.text ?? "Off")
//                    .font(.system(size: 14, weight: .bold))
//                if let secondary = isOn ? model.activeState.secondaryText : model.inactiveState.secondaryText, !secondary.isEmpty {
//                    Text(secondary)
//                        .font(.system(size: 12))
//                        .foregroundColor(.gray)
//                }
//            }
//        }
//        .toggleStyle(SwitchToggleStyle(tint: Color(hex: model.toggleColor ?? "#ffffff")))
//    }
//}
