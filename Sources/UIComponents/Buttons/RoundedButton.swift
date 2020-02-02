//
//  RoundedButton.swift
//  
//
//  Created by Jordan Gustafson on 2/2/20.
//

import UIKit

@available(iOS 10.0, *)
public class RoundedButton: PressableButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureView()
    }
    
    private func configureView() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
}

