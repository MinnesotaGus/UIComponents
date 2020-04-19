//
//  RoundedPaddedBackgroundModifier.swift
//  Beans
//
//  Created by Jordan Gustafson on 3/1/20.
//  Copyright © 2020 Jordan Gustafson. All rights reserved.
//

import SwiftUI

/// Modifier that adds a rounded padded background to the view
public struct RoundedPaddedBackgroundModifier: ViewModifier {
    
    let paddingInsets: EdgeInsets?
    let backgroundColor: Color
    let cornerRadius: CGFloat
    
    public init(paddingInsets: EdgeInsets? = nil,
         backgroundColor: Color = Color(UIColor.secondarySystemBackground),
         cornerRadius: CGFloat = 8.0) {
        self.paddingInsets = paddingInsets
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }
    
    public func body(content: Content) -> some View {
        if let paddingInsets = paddingInsets {
            return AnyView(content.padding(paddingInsets)
                .background(backgroundColor)
                .cornerRadius(cornerRadius))
        } else {
            return AnyView(content.padding()
                .background(backgroundColor)
                .cornerRadius(cornerRadius))
        }
    }
    
}

extension View {
    
    /// Adds a rounded padded background to the view
    /// - Parameters:
    ///   - paddingInsets: Insets of the desired padding
    ///   - backgroundColor: The background color to apply
    ///   - cornerRadius: The corner radius of the background
    /// - Returns: The modified view
    public func roundedPaddedBackground(paddingInsets: EdgeInsets? = nil,
                                        backgroundColor: Color = Color(UIColor.secondarySystemBackground),
                                        cornerRadius: CGFloat = 8.0) -> some View {
        return ModifiedContent(content: self,
                               modifier: RoundedPaddedBackgroundModifier(paddingInsets: paddingInsets,
                                                                         backgroundColor: backgroundColor,
                                                                         cornerRadius: cornerRadius))
    }

}

