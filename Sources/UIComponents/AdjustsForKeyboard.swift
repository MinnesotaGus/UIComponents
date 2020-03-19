//
//  AdjustsForKeyboard.swift
//  
//
//  Created by Jordan Gustafson on 3/1/20.
//

import UIKit
import SwiftUI
import Combine


//From https://stackoverflow.com/a/57147043
public struct AdjustsForKeyboard: ViewModifier {

    @State var currentHeight: CGFloat = 0
    
    private let keyboardWillOpen = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .map { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect }
        .map { $0.height }

    private let keyboardWillHide =  NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in CGFloat.zero }
    
    private let keyboardFrameWillChange = NotificationCenter.default
        .publisher(for: UIResponder.keyboardDidChangeFrameNotification)
        .map { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect }
        .map { $0.height }
    
    public init() {
        
    }

    public func body(content: Content) -> some View {
        content
            .padding(.bottom, currentHeight)
            .edgesIgnoringSafeArea(currentHeight == 0 ? Edge.Set() : .bottom)
            .onAppear(perform: subscribeToKeyboardEvents)
    }

    private func subscribeToKeyboardEvents() {
        _ = keyboardWillOpen
            .merge(with: keyboardFrameWillChange)
            .merge(with: keyboardWillHide)
            .subscribe(on: RunLoop.main)
            .assign(to: \.currentHeight, on: self)
        
    }
    
}

