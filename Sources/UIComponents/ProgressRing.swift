//
//  ProgressRing.swift
//  
//
//  Created by Jordan Gustafson on 6/13/20.
//

import SwiftUI

/// Simple Ring View for showing Progress
public struct ProgressRing: View {
    
    private let value: Double
    private let backgroundColor: Color?
    private let foregroundColor: Color
    private let lineWidth: CGFloat
    
    public init(value: Double,
                backgroundColor: Color? = Color(UIColor.secondarySystemBackground),
                foregroundColor: Color = Color.black,
                lineWidth: CGFloat = 10) {
        self.value = value
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.lineWidth = lineWidth
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            if backgroundColor != nil {
                Circle()
                    .stroke(lineWidth: lineWidth - 1)
                    .foregroundColor(backgroundColor!)
            }
            Circle()
                .trim(from: 0, to: CGFloat(value))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .foregroundColor(foregroundColor)
                .rotationEffect(Angle(degrees: -90))
        }
        .scaledToFit()
    }
    
}

//MARK: - Previews

struct TestView: View {
    
    @State private var sliderValue: Double = 0
    
    var body: some View {
        VStack {
            ProgressRing(value: $sliderValue.wrappedValue / 10,
                         foregroundColor: .red,
                         lineWidth: 10)
                .frame(width: 128)
            Slider(value: $sliderValue, in: 0...10)
                .padding(30)
        }.padding()
    }
    
}

struct TestView_Previews: PreviewProvider {
    
    static var previews: some View {
        TestView().previewDevice(PreviewDevice(rawValue: "iPhone X"))
    }
    
}
