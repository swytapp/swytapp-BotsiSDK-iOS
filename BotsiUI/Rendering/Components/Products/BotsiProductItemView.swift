////
////  BotsiProductItemView.swift
////  Botsi
////
////  Created by Kostiantyn Antoniuk on 18.06.2025.
////
//
//import SwiftUI
//
//@available(iOS 15.0, *)
//struct BotsiProductItemView: BlockView {
//    
//    @StateObject private var vm: BotsiProductItemViewModel
//    
//    init(viewModel: BotsiProductItemViewModel) {
//        _vm = StateObject(wrappedValue: viewModel)
//    }
//
//    var body: some View {
//        Button(action: vm.select) {
//            HStack {
//                VStack(alignment: .leading) {
//                    Text(vm.title)
//                    
//                    if let price = vm.price {
//                        Text(price).font(.caption)
//                    }
//                }
//                
//                Spacer()
//                
//                if vm.isSelected {
//                    Image(systemName: "checkmark")
//                }
//            }
//            .padding().background(vm.isSelected ? Color.blue.opacity(0.1) : Color.clear)
//            .animation(.default, value: vm.isSelected)
//        }
//    }
//}
