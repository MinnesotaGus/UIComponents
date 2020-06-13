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
    private let maxValue: Double
    private let displayText: String?
    private let style: Stroke
    private let backgroundEnabled: Bool
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let lineWidth: CGFloat
    
    public init(value: Double,
         maxValue: Double,
         displayText: String?,
         style: Stroke = .line,
         backgroundEnabled: Bool = true,
         backgroundColor: Color = Color(UIColor.secondarySystemBackground),
         foregroundColor: Color = Color.black,
         lineWidth: CGFloat = 10) {
        self.value = value
        self.maxValue = maxValue
        self.displayText = displayText
        self.style = style
        self.backgroundEnabled = backgroundEnabled
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.lineWidth = lineWidth
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            if backgroundEnabled {
                Circle()
                    .stroke(lineWidth: self.lineWidth - 1)
                    .foregroundColor(self.backgroundColor)
            }
            Circle()
                .trim(from: 0, to: CGFloat(self.value / self.maxValue))
                .stroke(style: self.style.strokeStyle(lineWidth: self.lineWidth))
                .foregroundColor(self.foregroundColor)
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeIn)
        }
        .overlay(displayTextView(), alignment: .center)
        .scaledToFit()
    }
    
    private func displayTextView() -> some View {
        VStack {
            if displayText != nil {
                Text(displayText!)
                    .font(Font.body.monospacedDigit())
            }
        }
    }
    
}

//MARK: - Models

extension ProgressRing {
    
    public enum Stroke {
        case line
        case dotted
        
        func strokeStyle(lineWidth: CGFloat) -> StrokeStyle {
            switch self {
            case .line:
                return StrokeStyle(lineWidth: lineWidth,
                                   lineCap: .round)
            case .dotted:
                return StrokeStyle(lineWidth: lineWidth,
                                   lineCap: .round,
                                   dash: [12])
            }
        }
    }
    
}

//MARK: - Previews

struct TestView: View {
    
    @State private var sliderValue: Double = 0
    private let maxValue: Double = 10
    
    var body: some View {
        VStack {
            ProgressRing(value: $sliderValue.wrappedValue,
                           maxValue: self.maxValue,
                           displayText: String(format: "%.1d", sliderValue),
                           style: .line,
                           foregroundColor: .red,
                           lineWidth: 10)
                .frame(width: 64)
            Slider(value: $sliderValue,
                   in: 0...maxValue)
            .padding(30)
        }.padding()
    }
    
    
    
    
}

struct TestView_Previews: PreviewProvider {
    
    static var previews: some View {
        TestView().previewDevice(PreviewDevice(rawValue: "iPhone X"))
    }
    
}
