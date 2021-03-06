//
//  MaterialTextField.swift
//  
//
//  Created by Jordan Gustafson on 3/4/20.
//

import SwiftUI

public struct MaterialTextField: View {
    
    private let title: String
    
    @Binding private var text: String
    
    public var body: some View {
        VStack(alignment: .leading) {
            if !text.isEmpty {
                Text(title)
                    .id("Header")
                    .font(.caption)
                    .animation(.easeInOut)
                    .transition(.opacity)
            }
            TextField(text.isEmpty ? title : "",
                      text: $text,
                      onEditingChanged: editingChanged(_:),
                      onCommit: returnedPressed).id(title)
                .font(.body)
                .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                .background(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(UIColor.secondaryLabel), lineWidth: 1)
            )
        }
    }
    
    public init(title: String, text: Binding<String>) {
        self.title = title
        self._text = text.animation()
    }
    
    private func editingChanged(_ editing: Bool) {
        print("Editing: \(editing)")
    }
    
    private func returnedPressed() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}

//MARK: - Previews

struct MaterialTextField_Previews: PreviewProvider {
    
    static let title: String = "Name"
    @State static var text: String = ""
    
    static var previews: some View {
        MaterialTextField(title: title, text: $text)
            .previewLayout(.sizeThatFits).padding()
    }
    
}

