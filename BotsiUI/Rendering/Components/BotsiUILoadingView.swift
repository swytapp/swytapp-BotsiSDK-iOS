//
//  BotsiUILoadingView.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 20.10.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiUILoadingView: View {
    
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tint(.white)
            .scaleEffect(CGSize(width: 1.5, height: 1.5))
            .background {
                Color.black.opacity(0.5)
            }
            .ignoresSafeArea()
    }
}
