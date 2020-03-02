//
//  PrimaryButton.swift
//  
//
//  Created by Jordan Gustafson on 3/1/20.
//

import SwiftUI

public struct PrimaryButton<Content: View>: View {
    
    let content: Content
    let action: () -> Void
    
    public init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        Button(action: {
            self.action()
        }) {
            return content
        }
        .buttonStyle(PrimaryButtonStyle())
        .frame(minWidth: 128, minHeight: 44)

    }
}

struct PrimaryButtonStyle: ButtonStyle {
    
    public func makeBody(configuration: PrimaryButtonStyle.Configuration) -> some View {
        configuration.label
            .font(Font.subheadline.bold())
            .foregroundColor(Color.white)
            .padding()
            .background(Color.orange)
            .compositingGroup()
            .animation(.easeInOut(duration: 0.33))
            .cornerRadius(8.0, antialiased: true)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            PrimaryButton(action: {
                print("Save tapped")
            }) {
                Text("Light mode")
            }.previewLayout(.sizeThatFits).padding()
            PrimaryButton(action: {
                print("Save tapped")
            }) {
                Text("Dark mode")
            }.environment(\.colorScheme, .dark)
                .previewLayout(.sizeThatFits).padding()
        }
    }
}

