//
//  SelectedModifier.swift
//  
//
//  Created by Jordan Gustafson on 3/21/20.
//

import SwiftUI

public struct SelectedModifier: ViewModifier {
    
    let isSelected: Bool
    let selectedColor: Color
    let cornerRadius: CGFloat
    
    public init(isSelected: Bool,
                selectedColor: Color = .orange,
                cornerRadius: CGFloat = 8.0) {
        self.isSelected = isSelected
        self.selectedColor = selectedColor
        self.cornerRadius = cornerRadius
    }
    
    public func body(content: Content) -> some View {
        if isSelected {
            return AnyView(content.overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(selectedColor, lineWidth: 1)))
        } else {
            return AnyView(content)
        }
    }
    
}

