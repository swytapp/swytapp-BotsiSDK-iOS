//
//  BotsiImageBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiImageBlockView: View {
    
    let model: BotsiImageModel

    var body: some View {
        let padding = model.padding
        VStack {
            AsyncImage(url: URL(string: model.image)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: model.height?.toCGFloat(default: 150))
                case .failure(_):
                    Color.clear
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }
        }
        .padding(.leading, padding.left)
        .padding(.top, padding.top)
        .padding(.trailing, padding.right)
        .padding(.bottom, padding.bottom)
        .offset(y: model.verticalOffset?.toCGFloat() ?? 0)
    }
}
