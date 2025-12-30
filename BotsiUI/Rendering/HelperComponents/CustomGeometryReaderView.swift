//
//  SwiftUIView.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 29.08.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct CustomGeometryReaderView<Content: View>: View {
    
    @ViewBuilder let content: (CGSize) -> Content
    
    private struct AreaReader: Shape {
        @Binding public var size: CGSize
        
        func path(in rect: CGRect) -> Path {
            Task { @MainActor in
                size = rect.size
            }
            return Rectangle().path(in: rect)
        }
    }
    
    @State private var size = CGSize.zero
    
    public var body: some View {
        AreaReader(size: $size).foregroundColor(.clear)
            .overlay(Group {
                if size != .zero {
                    content(size)
                }
            })
    }
}
