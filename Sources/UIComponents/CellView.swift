//
//  CellView.swift
//  
//
//  Created by Jordan Gustafson on 4/19/20.
//

import SwiftUI

/// View that wraps this given content in a cell style view
public struct CellView<Content: View, Accesory: View>: View {
    
    public let isSelected: Bool
    public let backgroundColor: Color
    public let content: Content
    public let accessory: Accesory
    
    public var body: some View {
        HStack {
            content
            Spacer()
            accessory.layoutPriority(1.0)
        }
        .roundedPaddedBackground(backgroundColor: backgroundColor)
        .selectedOutline(isSelected: isSelected)
        .backwardsCompatibleHoverEffect()
    }
    
    public init(isSelected: Bool,
                backgroundColor: Color = Color(UIColor.secondarySystemBackground),
                @ViewBuilder contentBuilder: () -> Content,
                @ViewBuilder accessoryBuilder: () -> Accesory) {
        self.isSelected = isSelected
        self.backgroundColor = backgroundColor
        self.content = contentBuilder()
        self.accessory = accessoryBuilder()
    }
    
}

//MARK: - Previews

struct CellView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            Group {
                CellView(isSelected: false, contentBuilder: {
                    VStack(alignment: .leading) {
                        Text("Title Label")
                            .font(.headline)
                        Text("Description Label")
                            .font(.subheadline)
                    }
                }, accessoryBuilder: {
                    LocalizedChevron()
                })
                .padding()
                .background(Color(.systemBackground))
                .previewLayout(.sizeThatFits)
                
                
                CellView(isSelected: true, contentBuilder: {
                    VStack(alignment: .leading) {
                        Text("Title Label")
                            .font(.headline)
                        Text("Description Label")
                            .font(.subheadline)
                    }
                }, accessoryBuilder: {
                    LocalizedChevron()
                })
                .padding()
                .background(Color(.systemBackground))
                .previewLayout(.sizeThatFits)
            }
            
            Group {
                CellView(isSelected: false, contentBuilder: {
                    VStack(alignment: .leading) {
                        Text("Title Label")
                            .font(.headline)
                        Text("Description Label")
                            .font(.subheadline)
                    }
                }, accessoryBuilder: {
                    LocalizedChevron()
                })
                .padding()
                .background(Color(.systemBackground))
                .previewLayout(.sizeThatFits)
                
                CellView(isSelected: true, contentBuilder: {
                    VStack(alignment: .leading) {
                        Text("Title Label")
                            .font(.headline)
                        Text("Description Label")
                            .font(.subheadline)
                    }
                }, accessoryBuilder: {
                    LocalizedChevron()
                })
                .padding()
                .background(Color(.systemBackground))
                .previewLayout(.sizeThatFits)
            }.environment(\.colorScheme, .dark)
        }
    }
    
}

