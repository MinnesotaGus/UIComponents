//
//  SelectedModifier.swift
//  
//
//  Created by Jordan Gustafson on 3/21/20.
//

import SwiftUI

/// Modifier that adds a selected outline to the view
public struct SelectedOutlineModifier: ViewModifier {
    
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
                    .stroke(selectedColor, lineWidth: 1))).id(changeId())
        } else {
            return AnyView(content).id(changeId())
        }
    }
    
    /// Returns a change id that represents the current state of the view
    /// - Returns: `ChangeId`
    private func changeId() -> ChangeId {
        return ChangeId(isSelected: isSelected,
                        selectedColor: selectedColor,
                        cornerRadius: cornerRadius)
    }
    
    /// Hashable struct that represents the current state of the view
    struct ChangeId: Hashable {
        let isSelected: Bool
        let selectedColor: Color
        let cornerRadius: CGFloat
    }
    
}

extension View {
    
    /// Adds a selected modifier to the view if `isSelected` is true
    /// - Parameters:
    ///   - isSelected: Bool for whether or not to show the selected modifier
    ///   - selectedColor: The color to use for the selection modifier
    ///   - cornerRadius: The corner radius of the modifier
    /// - Returns: The modified view
    public func selectedOutline(isSelected: Bool,
                                selectedColor: Color = .orange,
                                cornerRadius: CGFloat = 8.0) -> some View {
        return ModifiedContent(content: self, modifier: SelectedOutlineModifier(isSelected: isSelected,
                                                                                selectedColor: selectedColor,
                                                                                cornerRadius: cornerRadius))
    }
    
}

