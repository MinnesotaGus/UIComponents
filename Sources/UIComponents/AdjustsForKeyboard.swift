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
    
    private let showsHideKeyboardButton: Bool
    @ObservedObject private var keyboardListener: KeyboardListener
    
    public init(showsHideKeyboardButton: Bool = true) {
        self.showsHideKeyboardButton = showsHideKeyboardButton
        self.keyboardListener = KeyboardListener()
    }
    
    public func body(content: Content) -> some View {
        GeometryReader { proxy in
            VStack {
                content
                    .edgesIgnoringSafeArea(.bottom)
                    .overlay(self.hideKeyboardButtonView(), alignment: .bottomTrailing)
                    .frame(height: ((proxy.size.height + self.safeAreaPadding(for: proxy)) - self.keyboardListener.keyboardHeight), alignment: .top)
                Spacer()
            }
        }
        .animation(.easeOut(duration: 0.16))
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func hideKeyboardButtonView() -> some View {
        VStack {
            if keyboardListener.keyboardHeight > 0 && showsHideKeyboardButton {
                Button(action: { self.hideKeyboard() }) {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                        .accentColor(.orange)
                        .shadow(radius: 1)
                }.transition(.opacity)
            }
            Spacer()
                .frame(height: 8)
        }
    }
    
    private func safeAreaPadding(for proxy: GeometryProxy) -> CGFloat {
        return keyboardListener.keyboardHeight > 0 ? proxy.safeAreaInsets.bottom : 0.0
    }

}

extension View {
    
    public func avoidsKeyboard(showsHideKeyboardButton: Bool = true) -> some View {
        ModifiedContent(content: self, modifier: AdjustsForKeyboard(showsHideKeyboardButton: true))
    }
    
}

fileprivate class KeyboardListener: ObservableObject {
 
    @Published var keyboardHeight: CGFloat = 0
    
    private var keyboardCancelables: Set<AnyCancellable> = Set()
    
    private let keyboardWillOpen = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .map { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect }
        .map { $0.height }
    
    private let keyboardWillHide =  NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in CGFloat.zero }
    
    init() {
        subscribeToKeyboardEvents()
    }
    
    private func subscribeToKeyboardEvents() {
        keyboardWillOpen
            .merge(with: keyboardWillHide)
            .subscribe(on: RunLoop.main)
            .sink(receiveValue: { height in
                withAnimation {
                    self.keyboardHeight = height
                }
            })
            .store(in: &keyboardCancelables)
    }
    
}

