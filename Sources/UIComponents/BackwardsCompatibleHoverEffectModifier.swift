//
//  BackwardsCompatibleHoverEffectModifier.swift
//  
//
//  Created by Jordan Gustafson on 3/27/20.
//

import SwiftUI

/// Wraps the SwiftUI `.hoverEffect` so it can be used without have to wrap your whole `View` in a `#available(iOS 13.4, *)` block
public struct BackwardsCompatibleHoverEffectModifier: ViewModifier {
    
    private let effect: Effect
    
    public init(effect: Effect = .automatic) {
        self.effect = effect
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        if #available(iOS 13.4, *) {
            content
                .hoverEffect(effect.hoverEffect)
        } else {
            content
        }
    }
    
}

extension View {
    
    /// Adds a hover effect modifier to the view
    /// - Parameter effect: The effect to add
    /// - Returns: The modified view
    public func backwardsCompatibleHoverEffect(effect: BackwardsCompatibleHoverEffectModifier.Effect = .automatic) -> some View {
        return ModifiedContent(content: self,
                               modifier: BackwardsCompatibleHoverEffectModifier(effect: effect))
    }
    
}


//MARK: - Models

extension BackwardsCompatibleHoverEffectModifier {
    
    /// Wraps Apples `HoverEffect`
    public enum Effect {
        
        case automatic
        case highlight
        case lift
        
        @available(iOS 13.4, *)
        var hoverEffect: HoverEffect {
            switch self {
            case .automatic:
                return .automatic
            case .highlight:
                return .highlight
            case .lift:
                return .lift
            }
        }
        
    }
    
}

