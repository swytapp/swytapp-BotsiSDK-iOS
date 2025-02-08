//
//  BotsiUIBottomSheetView.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import Botsi
import SwiftUI


@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct BotsiUIBottomSheetView: View {
    @EnvironmentObject var viewModel: BotsiBottomSheetViewModel

    @State private var offset: CGFloat = UIScreen.main.bounds.height

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .frame(maxHeight: .infinity)
            
            BotsiUIElementView(viewModel.bottomSheet.content)
                                
                .withScreenId(viewModel.id)
                .offset(y: offset)
                .onAppear {
                    offset = viewModel.isPresented ? 0.0 : UIScreen.main.bounds.height
                }
        }
        .ignoresSafeArea()
        .onChange(of: viewModel.isPresented) { newValue in
            withAnimation(newValue ? .easeOut : .linear) {
                offset = newValue ? 0.0 : UIScreen.main.bounds.height
            }
        }
    }
}

#endif
