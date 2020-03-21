//
//  MultilineTextView.swift
//  Beans
//
//  Created by Jordan Gustafson on 2/22/20.
//  Copyright © 2020 Jordan Gustafson. All rights reserved.
//

import SwiftUI

public struct MultilineTextView: UIViewRepresentable {
    
    @Binding var text: String
    
    public init(text: Binding<String>) {
        self._text = text
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    public func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isScrollEnabled = true
        view.isEditable = true
        view.isUserInteractionEnabled = true
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.delegate = context.coordinator
        return view
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
}

extension MultilineTextView {
    
    public class Coordinator : NSObject, UITextViewDelegate {

        let text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }

        public func textViewDidChange(_ textView: UITextView) {
            text.wrappedValue = textView.text
        }
        
    }
    
}

//MARK: - Previews

struct MultiLineTextView_Previews: PreviewProvider {
    
    @State static var text: String = ""
    
    static var previews: some View {
        MultilineTextView(text: $text)
    }
    
}

