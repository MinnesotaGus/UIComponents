//
//  ActivityIndicatorView.swift
//  
//
//  Created by Jordan Gustafson on 4/14/20.
//

import SwiftUI
import UIKit

public struct ActivityIndicatorView: UIViewRepresentable {

    public let style: UIActivityIndicatorView.Style
    
    public init(style: UIActivityIndicatorView.Style) {
        self.style = style
    }

    public func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        uiView.startAnimating()
    }
    
}

struct ActivityIndicatorView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            ActivityIndicatorView(style: .medium)
        }
    }
    
}

