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


struct GrabBar_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            Group {
                GrabBar(color: .gray)
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    .previewLayout(.sizeThatFits)
            }
            
            Group {
                GrabBar(color: .gray)
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    .previewLayout(.sizeThatFits)
            }.preferredColorScheme(.dark)
        }
    }
    
}
