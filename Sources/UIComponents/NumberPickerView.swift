//
//  NumberPickerView.swift
//  Beans
//
//  Created by Jordan Gustafson on 2/15/20.
//  Copyright © 2020 Jordan Gustafson. All rights reserved.
//

import SwiftUI
import Combine

public struct NumberPickerView: View {
    
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    @Binding public var value: Double
    
    @State public var contentOffset: CGFloat = 0.0
    
    public var number: Double {
        let value = Double(contentOffset / 100.0)
        guard value >= 0.0 else {
            return 0.0
        }
        return value
    }
    
    public let minValue: Double
    public let maxValue: Double
    
    private let tickGroups: [TickMarkGroup]
    
    public init(value: Binding<Double>, minValue: Double, maxValue: Double) {
        self._value = value
        self.minValue = minValue
        self.maxValue = maxValue
        let array = Array(Int(minValue) ..< Int(maxValue))
        self.tickGroups = array.map { _ in TickMarkGroup(numberOfTicks: 10) }
    }
    
    public var body: some View {
        TrackableScrollView(.horizontal, showIndicators: false, contentOffset: $contentOffset) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(tickGroups, id: \.self) { (tickMarkGroup) in
                    return tickMarkGroup
                }
            }
        }.overlay(
            Text("\(Self.formatter.string(from: NSNumber(value: number)) ?? "")")
                .font(Font.body.monospacedDigit())
                .padding()
                .background(Color.orange).cornerRadius(8),
            alignment: .center)
    }
}

struct TickMarkGroup: View, Hashable {
    
    let ticks: [Int]
    
    var body: some View {
        ForEach(ticks, id: \.self) { (tick) in
            return TickMark(style: (tick % 10) == 0 ? .tall : .short, width: 2.0)
        }.drawingGroup()
    }
    
    init(numberOfTicks: Int) {
        let safe = numberOfTicks >= 0 ? numberOfTicks : 0
        self.ticks = Array(0 ..< safe)
    }
    
    
}

struct TickMark: View {
    
    enum Style {
        case short
        case tall
        
        var heightMultiplier: CGFloat {
            switch self {
            case .tall:
                return 1.0
            case .short:
                return 0.67
            }
        }
        
    }
    
    let style: Style
    let width: CGFloat
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                VerticalLineShape()
                    .stroke(Color.orange, lineWidth: self.width)
                    .frame(height: proxy.size.height * self.style.heightMultiplier, alignment: .bottom)
            }
        }.frame(width: width, height: 128)
    }
    
}


struct VerticalLineShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
    
}

struct NumberPickerView_Previews: PreviewProvider {
    
    @State static private var value: Double = 0.0
    
    static var previews: some View {
        NumberPickerView(value: $value, minValue: 0.0, maxValue: 256.0)
    }
    
}

