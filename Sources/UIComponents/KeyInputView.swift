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
    
    private let keyPressedAction: (UIKey) -> Void
    
    public func makeCoordinator() -> KeyCoordinator {
        return KeyCoordinator()
    }
    
    public func makeUIViewController(context: Context) -> KeyInputViewController {
        let viewController = KeyInputViewController()
        viewController.eventPublisher.sink { (event) in
            switch event {
            case let .pressed(key):
                self.keyPressedAction(key)
            case .released:
                break
            }
        }.store(in: &context.coordinator.cancellables)
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: KeyInputViewController, context: Context) {
        //
    }
    
    public init(keyPressedAction: @escaping (UIKey) -> Void) {
        self.keyPressedAction = keyPressedAction
    }
    
    public class KeyCoordinator {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        
    }
    
}


@available(iOS 13.4, *)
public final class KeyInputViewController: UIViewController {
    
    public var eventPublisher: AnyPublisher<ViewEvent, Never> {
        return eventSubject.eraseToAnyPublisher()
    }
    
    private let eventSubject: PassthroughSubject<ViewEvent, Never> = PassthroughSubject()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }

        eventSubject.send(.pressed(key: key))
    }
    
    public override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }

        eventSubject.send(.released(key: key))
    }
    
    /// Defines the events that the view can publish
    public enum ViewEvent: Equatable {
        /// Represents the event where a key on the hardware keyboard is pressed in
        case pressed(key: UIKey)
        /// Represents the event where a key on the hardware keyboard is released
        case released(key: UIKey)
    }
    
}

