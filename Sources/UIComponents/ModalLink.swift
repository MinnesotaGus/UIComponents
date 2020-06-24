//
//  ModalLink.swift
//  
//
//  Created by Jordan Gustafson on 6/20/20.
//

import SwiftUI

/// `View` for presenting a modal view
public struct ModalLink<Content, Destination>: View where Content: View, Destination: View {
    
    let isPresented: Binding<Bool>
    let content: () -> Content
    let destination: () -> Destination
    let transition: ModalTransition
    
    public var body: some View {
        ZStack {
            if self.isPresented.wrappedValue {
                self.destination()
                    .transition(self.transition.transition)
            } else {
                self.content()
            }
        }
    }
    
    public init(isPresented: Binding<Bool>, transition: ModalTransition, @ViewBuilder destination: @escaping () -> Destination, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.destination = destination
        self.isPresented = isPresented
        self.transition = transition
    }
    
}

/// `ViewModifier` for adding a modal presentation link to a view
public struct ModalLinkViewModifier<Destination>: ViewModifier where Destination: View {
    
    let isPresented: Binding<Bool>
    let transition: ModalTransition
    let destination: () -> Destination
    
    public func body(content: Self.Content) -> some View {
        ModalLink(isPresented: isPresented, transition: transition, destination: {
            self.destination()
        }, content: {
            content
        })
    }
    
}

/// Represents the different transitions that can be used when presenting a modal link
public enum ModalTransition {
    
    case popUp
    case scaleAndFade
    case custom(AnyTransition)
    
    public var transition: AnyTransition {
        switch self {
        case .popUp:
            return AnyTransition.move(edge: .bottom).combined(with: .opacity)
        case .scaleAndFade:
            return AnyTransition.scale.combined(with: .opacity)
        case let .custom(customTransition):
            return customTransition
        }
    }
    
}


//MARK: - View Extentions
extension View {
    
    /// Presents a modal view based on the `isPresented` flag
    /// - Parameters:
    ///   - isPresented: `Biding<Bool>` that determines whether or not the modal is presented
    ///   - transition: The transition to use when presenting the modal
    ///   - destination: The view to be presented modally
    public func modalLink<Destination: View>(isPresented: Binding<Bool>, transition: ModalTransition, destination: @escaping () -> Destination) -> some View {
        self.modifier(ModalLinkViewModifier(isPresented: isPresented, transition: transition, destination: destination))
    }
    
}
