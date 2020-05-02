//
//  GrabBar.swift
//  
//
//  Created by Jordan Gustafson on 5/1/20.
//

import SwiftUI

public struct GrabBar: View {
    
    public let color: Color
    
    public var body: some View {
        Capsule(style: .continuous)
            .background(color)
            .frame(width: 32, height: 2, alignment: .center)
    }
    
    public init(color: Color) {
        self.color = color
    }
    
}

