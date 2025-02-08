//
//  BotsiUISectionView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import Botsi
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct BotsiUISectionView: View {
    @EnvironmentObject var viewModel: BotsiSectionsViewModel
    
    var section: VC.Section

    init(_ section: VC.Section) {
        self.section = section
    }

    var body: some View {
        let index = viewModel.selectedIndex(for: section)

        if let content = section.content[safe: index] {
            BotsiUIElementView(content)
        }
    }
}

#endif
