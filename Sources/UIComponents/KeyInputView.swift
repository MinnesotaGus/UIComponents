//
//  KeyInputView.swift
//  
//
//  Created by Jordan Gustafson on 6/21/20.
//

import Combine
import SwiftUI

@available(iOS 13.4, *)
public struct KeyInputView: UIViewControllerRepresentable {
    
    private let viewModel: KeyInputViewModel
    
    public func makeUIViewController(context: Context) -> KeyInputViewController {
        return KeyInputViewController(viewModel: viewModel)
    }
    
    public func updateUIViewController(_ uiViewController: KeyInputViewController, context: Context) {
        //
    }
    
    public init(viewModel: KeyInputViewModel) {
        self.viewModel = viewModel
    }
    
}

@available(iOS 13.4, *)
public final class KeyInputViewModel {
    
    public var eventPublisher: AnyPublisher<ViewEvent, Never> {
        return eventSubject.eraseToAnyPublisher()
    }
    
    private let eventSubject: PassthroughSubject<ViewEvent, Never> = PassthroughSubject()
    
    private let handledKeyCodes: Set<UIKeyboardHIDUsage>
    
    init(handledKeyCodes: Set<UIKeyboardHIDUsage>) {
        self.handledKeyCodes = handledKeyCodes
    }
    
    /// Call this when the user presses a key on the hardware keybaord
    /// - Parameter key: The key that was pressed
    /// - Returns: Whether or not the view model can handle the key press
    func keyPressed(key: UIKey) -> Bool {
        if handledKeyCodes.contains(key.keyCode) {
            eventSubject.send(.pressed(key: key))
            return true
        } else {
            return false
        }
    }
    
    /// Call this when the user releases a key on the hardware keybaord
    /// - Parameter key: The key that was pressed
    /// - Returns: Whether or not the view model can handle the key press
    func keyReleased(key: UIKey) -> Bool {
        if handledKeyCodes.contains(key.keyCode) {
            eventSubject.send(.released(key: key))
            return true
        } else {
            return false
        }
    }
    
    /// Defines the events that the view can publish
    public enum ViewEvent {
        /// Represents the event where a key on the hardware keyboard is pressed in
        case pressed(key: UIKey)
        /// Represents the event where a key on the hardware keyboard is released
        case released(key: UIKey)
    }
    
    
}

@available(iOS 13.4, *)
public final class KeyInputViewController: UIViewController {
    
    private let viewModel: KeyInputViewModel
    
    init(viewModel: KeyInputViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }

        let handledKeyPress = viewModel.keyPressed(key: key)
        
        if !handledKeyPress {
            super.pressesBegan(presses, with: event)
        }
    }
    
    public override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }

        let handledKeyRelease = viewModel.keyReleased(key: key)
        
        if !handledKeyRelease {
            super.pressesEnded(presses, with: event)
        }
    }
    
}

