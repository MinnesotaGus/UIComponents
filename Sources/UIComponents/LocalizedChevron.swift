//
//  LocalizedChevron.swift
//  
//
//  Created by Jordan Gustafson on 4/24/20.
//

import SwiftUI

/// Chevron Image view that respects `LayoutDirection`
public struct LocalizedChevron: View {
    
    @Environment(\.layoutDirection) var layoutDirection: LayoutDirection
    
    public var body: some View {
        if layoutDirection == .leftToRight {
            return Image(systemName: "chevron.right")
        } else {
            return Image(systemName: "chevron.left")
        }
    }
    
    public init() { }
    
}

//MARK: - Previews

struct LocalizedChevron_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            Group {
                LocalizedChevron()
                    .padding()
                    .background(Color(.systemBackground))
                    .previewLayout(.sizeThatFits)
                    .environment(\.layoutDirection, .leftToRight)
                LocalizedChevron()
                    .padding()
                    .previewLayout(.sizeThatFits)
                    .environment(\.layoutDirection, .rightToLeft)
            }
            Group {
                LocalizedChevron()
                    .padding()
                    .background(Color(.systemBackground))
                    .background(Color(.systemBackground))
                    .previewLayout(.sizeThatFits)
                    .environment(\.layoutDirection, .leftToRight)
                LocalizedChevron()
                    .padding()
                    .background(Color(.systemBackground))
                    .previewLayout(.sizeThatFits)
                    .environment(\.layoutDirection, .rightToLeft)
            }.environment(\.colorScheme, .dark)
        }
    }
    
}

