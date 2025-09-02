//
//  FooterPaddingFillerView.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 29.08.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct FooterPaddingFillerView: View {
    var height: Double

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .frame(height: height)
        }
        .frame(height: height)
    }
}
