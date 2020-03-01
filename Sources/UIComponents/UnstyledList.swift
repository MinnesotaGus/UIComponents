//
//  UnstyledList.swift
//  Beans
//
//  Created by Jordan Gustafson on 3/1/20.
//  Copyright © 2020 Jordan Gustafson. All rights reserved.
//

import SwiftUI

public struct UnstyledList<Content: View>: View {
    
    let content: Content
    
    public var body: some View {
        List {
            content
        }.listStyle(PlainListStyle())
            .listRowBackground(Color.clear)
            .onAppear(perform: {
                UITableView.appearance().separatorStyle = .none
            })
    }
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
}

struct UnstyledList_Previews: PreviewProvider {
    
    static var previews: some View {
        UnstyledList {
            Button(action: {
                print("Pressed")
            }) {
                Text("Hello")
                    .padding()
                    .frame(maxWidth: CGFloat.greatestFiniteMagnitude, minHeight: 44)
                    .background(Color.orange)
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
                
            }.buttonStyle(PlainButtonStyle())
        }
    }
    
}

