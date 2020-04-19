//
//  CellView.swift
//  
//
//  Created by Jordan Gustafson on 4/19/20.
//

import SwiftUI

/// View that wraps this given content in a cell style view
struct CellView<Content: View>: View {
    
    let showsChevron: Bool
    let isSelected: Bool
    let backgroundColor: Color
    let content: Content
    
    var body: some View {
        HStack {
            content
            Spacer()
            if showsChevron {
                Image(systemName: "chevron.right").layoutPriority(1.0)
            }
        }
        .roundedPaddedBackground(backgroundColor: backgroundColor)
        .selectedOutline(isSelected: isSelected)
        .backwardsCompatibleHoverEffect()
    }
    
    init(showsChevron: Bool,
         isSelected: Bool,
         backgroundColor: Color = Color(UIColor.secondarySystemBackground),
         @ViewBuilder contentBuilder: () -> Content) {
        self.showsChevron = showsChevron
        self.isSelected = isSelected
        self.backgroundColor = backgroundColor
        self.content = contentBuilder()
    }
    
}

//MARK: - Previews

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Group {
                CellView(showsChevron: true, isSelected: false) {
                    VStack(alignment: .leading) {
                        Text("Title Label")
                            .font(.headline)
                        Text("Description Label")
                            .font(.subheadline)
                    }
                }
                .padding()
                .previewLayout(.sizeThatFits)
                
                CellView(showsChevron: false, isSelected: true) {
                    VStack(alignment: .leading) {
                        Text("Title Label")
                            .font(.headline)
                        Text("Description Label")
                            .font(.subheadline)
                    }
                }
                .padding()
                .previewLayout(.sizeThatFits)
            }
            
            Group {
                CellView(showsChevron: true, isSelected: false) {
                    VStack(alignment: .leading) {
                        Text("Title Label")
                            .font(.headline)
                        Text("Description Label")
                            .font(.subheadline)
                    }
                }
                .padding()
                .previewLayout(.sizeThatFits)
                
                CellView(showsChevron: false, isSelected: true) {
                    VStack(alignment: .leading) {
                        Text("Title Label")
                            .font(.headline)
                        Text("Description Label")
                            .font(.subheadline)
                    }
                }
                .padding()
                .previewLayout(.sizeThatFits)
            }.environment(\.colorScheme, .dark)
        }
    }
}

