////
////  BotsiNoSwitchCardView.swift
////  Botsi
////
////  Created by Konstantin on 31.07.2025.
////
//
//import SwiftUI
//
//
//@available(iOS 15.0, *)
//struct BotsiNoSwitchCardView: View {
//    
//    @ObservedObject var viewModel: BotsiNoSwitchCardViewModel
//    
//    let isSelected: Bool
//
//    var body: some View {
//        ZStack(alignment: .top) {
//            VStack(spacing: 4) {
//                Text(viewModel.defaultText.text1)
//                    .font(.system(size: viewModel.text1Size))
//                    .foregroundStyle(viewModel.text1Color)
//                if !viewModel.defaultText.text2.isEmpty {
//                    Text(viewModel.defaultText.text2)
//                        .font(.system(size: viewModel.text2Size))
//                        .foregroundStyle(viewModel.text2Color)
//                }
//                if !viewModel.defaultText.text3.isEmpty {
//                    Text(viewModel.defaultText.text3)
//                        .font(.system(size: viewModel.text3Size))
//                        .foregroundStyle(viewModel.text3Color)
//                }
//                if !viewModel.defaultText.text4.isEmpty {
//                    Text(viewModel.defaultText.text4)
//                        .font(.system(size: viewModel.text4Size))
//                        .foregroundStyle(viewModel.text4Color)
//                }
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding()
//            .backgroundFill(viewModel.backgroundFill)
//            .cornerRadius(16)
//            .overlay(
//                RoundedRectangle(cornerRadius: viewModel.radius)
//                    .stroke(viewModel.borderColor)
//            )
//            
//            if viewModel.isBadge {
//                let badge = viewModel.badge
//                Text(badge?.badgeText ?? "")
//                    .font(.system(size: badge?.badgeTextSize.toCGFloat() ?? 0))
//                    .foregroundStyle(badge?.badgeTextColor?.toColor() ?? .clear)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(badge?.badgeColor.toColor() ?? .clear)
//                    .cornerRadius(12)
//                    .offset(y: -12)
//            }
//        }
//    }
//}
