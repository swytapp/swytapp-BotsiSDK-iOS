//
//  BotsiToggleControlView.swift
//  Botsi
//
//  Created by Konstantin on 13.07.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiToggleControlView: View {
    
    let model: BotsiToggleControlModel
    
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(model.activeState.text)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue))
    }
}
