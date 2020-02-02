//
//  PressableButton.swift
//  
//
//  Created by Jordan Gustafson on 2/2/20.
//

import UIKit

public class PressableButton: UIButton {
    
    private var size: Size = .normal
    
    public override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                pressed()
            } else {
                depressed()
            }
        }
    }
    
    private func pressed() {
        switch size {
        case .normal:
            UIView.animate(withDuration: 0.05, animations: {
                self.transform = self.transform.scaledBy(x: Size.small.rawValue/Size.normal.rawValue, y: Size.small.rawValue/Size.normal.rawValue)
            })
        case .small:
            break
        }
        size = .small
        
    }
    
    private func depressed() {
        switch size {
        case .normal:
            break
        case .small:
            UIView.animate(withDuration: 0.05, animations: {
                self.transform = self.transform.scaledBy(x: Size.normal.rawValue/Size.small.rawValue, y: Size.normal.rawValue/Size.small.rawValue)
            })
        }
        
        size = .normal
    }
    
}

//MARK: - Models

extension PressableButton {
    
    enum Size: CGFloat {
        case small = 0.95
        case normal = 1.0
    }
    
}

