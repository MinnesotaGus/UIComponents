//
//  NumberField.swift
//  
//
//  Created by Jordan Gustafson on 6/19/20.
//

import SwiftUI

public struct NumberField: View {
    
    @ObservedObject private var viewModel: NumberFieldViewModel
    
    public var body: some View {
        VStack(spacing: 16) {
            Spacer()
            HStack {
                Spacer()
                Text(viewModel.displayNumber)
                    .font(Font.largeTitle.monospacedDigit())
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
            }
            HStack {
                Spacer()
                NumberFieldKey(key: .seven) { key in
                    self.viewModel.tapped(key: key)
                }
                Spacer().frame(width: 16)
                NumberFieldKey(key: .eight) { key in
                    self.viewModel.tapped(key: key)
                }
                Spacer().frame(width: 16)
                NumberFieldKey(key: .nine) { key in
                    self.viewModel.tapped(key: key)
                }
                Spacer()
            }
            HStack {
                Spacer()
                NumberFieldKey(key: .four) { key in
                    self.viewModel.tapped(key: key)
                }
                Spacer().frame(width: 16)
                NumberFieldKey(key: .five) { key in
                    self.viewModel.tapped(key: key)
                }
                Spacer().frame(width: 16)
                NumberFieldKey(key: .six) { key in
                    self.viewModel.tapped(key: key)
                }
                Spacer()
            }
            HStack {
                Spacer()
                NumberFieldKey(key: .one) { key in
                    self.viewModel.tapped(key: key)
                }
                Spacer().frame(width: 16)
                NumberFieldKey(key: .two) { key in
                    self.viewModel.tapped(key: key)
                }
                Spacer().frame(width: 16)
                NumberFieldKey(key: .three) { key in
                    self.viewModel.tapped(key: key)
                }
                Spacer()
            }
            HStack {
                Spacer()
                NumberFieldKey(key: .decimalPoint) { key in
                    self.viewModel.tapped(key: key)
                }
                Spacer().frame(width: 16)
                NumberFieldKey(key: .zero) { key in
                    self.viewModel.tapped(key: key)
                }
                Spacer().frame(width: 16)
                NumberFieldKey(key: .clear) { key in
                    self.viewModel.tapped(key: key)
                }
                Spacer()
            }
        }.padding()
    }
    
    public init(number: Binding<Double>) {
        self.viewModel = NumberFieldViewModel(number: number)
    }
    
}

fileprivate class NumberFieldViewModel: ObservableObject {
    
    @Published var displayNumber: String = ""
    
    private let number: Binding<Double>
    
    private let decimalPrecision: Int = 3
    
    private var editingPlace: EditingPlace
    
    private var splitNumber: SplitNumber {
        didSet {
            updateNumber()
        }
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        return formatter
    }()
    
    init(number: Binding<Double>) {
        self.number = number
        let splitNumber = SplitNumber(number: number.wrappedValue)
        self.splitNumber = splitNumber
        if !splitNumber.postDecimalDigits.isEmpty && splitNumber.postDecimalDigits[0] != 0 {
            editingPlace = .trailing
        } else {
            editingPlace = .leading
        }
        
        numberFormatter.maximumFractionDigits = splitNumber.postDecimalDigits.count
        displayNumber = numberFormatter.string(from: NSNumber(value: number.wrappedValue)) ?? "0.0"
    }
    
    func tapped(key: NumberFieldKey.Key) {
        switch key {
        case .zero:
            append(number: 0)
        case .one:
            append(number: 1)
        case .two:
            append(number: 2)
        case .three:
            append(number: 3)
        case .four:
            append(number: 4)
        case .five:
            append(number: 5)
        case .six:
            append(number: 6)
        case .seven:
            append(number: 7)
        case .eight:
            append(number: 8)
        case .nine:
            append(number: 9)
        case .decimalPoint:
            if splitNumber.preDecimalDigits.isEmpty {
                splitNumber = splitNumber.with(updatedPreDecimalDigits: [])
            }
            editingPlace = .trailing
            updateNumber()
        case .clear:
            splitNumber = SplitNumber(preDecimalDigits: [], postDecimalDigits: [])
        }
    }
    
    private func append(number: Int) {
        switch editingPlace {
        case .leading:
            if splitNumber.preDecimalDigits.count == 1 && splitNumber.preDecimalDigits[0] == 0 {
                splitNumber = splitNumber.with(updatedPreDecimalDigits: [])
            }
            splitNumber = splitNumber.addingNumberToPreDecimalDigits(number)
        case .trailing:
            if splitNumber.postDecimalDigits.count == 1 && splitNumber.postDecimalDigits[0] == 0 {
                splitNumber = splitNumber.with(updatedPostDecimalDigits: [])
            }
            splitNumber = splitNumber.addingNumberToPostDecimalDigits(number)
        }
    }
    
    private func updateNumber() {
        var mutableLeading: Double = 0.0
        let numberOfLeadingNumbers = splitNumber.preDecimalDigits.count
        if numberOfLeadingNumbers > 0 {
            for i in 0...(numberOfLeadingNumbers - 1) {
                let exponent = pow(10, Double(numberOfLeadingNumbers - i - 1))
                mutableLeading += Double(splitNumber.preDecimalDigits[i]) * exponent
            }
        }
        
        var mutableTrailing: Double = 0.0
        let numberOfTrailingNumbers = splitNumber.postDecimalDigits.count
        if numberOfTrailingNumbers > 0 {
            for i in 0...(numberOfTrailingNumbers - 1) {
                mutableTrailing += Double(splitNumber.postDecimalDigits[i]) / pow(10, Double(i + 1))
            }
        }
        
        let newNumber = mutableLeading + mutableTrailing
        numberFormatter.maximumFractionDigits = splitNumber.postDecimalDigits.count
        if number.wrappedValue != newNumber {
            number.wrappedValue = newNumber
        }
        let formattedNumber = numberFormatter.string(from: NSNumber(value: newNumber)) ?? "0"
        if !formattedNumber.contains(".") && editingPlace == .trailing {
            displayNumber = formattedNumber + "."
        } else {
            displayNumber = formattedNumber
        }
    }
    
    enum EditingPlace {
        case leading
        case trailing
    }
    
    struct SplitNumber {
        
        let preDecimalDigits: [Int]
        let postDecimalDigits: [Int]
        
        init(number: Double) {
            let numberString = String(number)
            let separated = numberString.split(separator: ".")
            if let leadingRoundedString = separated.first, let leadingRounded = Int(String(leadingRoundedString)) {
                preDecimalDigits = String(describing: leadingRounded).compactMap { Int(String($0)) }
            } else {
                preDecimalDigits = []
            }
            
            if separated.count > 1, let trailingRounded = Int(String(separated[1])) {
                let trailingPlaced = String(describing: trailingRounded).compactMap { Int(String($0)) }
                postDecimalDigits = trailingPlaced
            } else {
                postDecimalDigits = []
            }
        }
        
        init(preDecimalDigits: [Int], postDecimalDigits: [Int]) {
            self.preDecimalDigits = preDecimalDigits
            self.postDecimalDigits = postDecimalDigits
        }
        
        func with(updatedPreDecimalDigits: [Int]) -> SplitNumber {
            return SplitNumber(preDecimalDigits: updatedPreDecimalDigits, postDecimalDigits: postDecimalDigits)
        }
        
        func with(updatedPostDecimalDigits: [Int]) -> SplitNumber {
            return SplitNumber(preDecimalDigits: preDecimalDigits, postDecimalDigits: updatedPostDecimalDigits)
        }
        
        func addingNumberToPreDecimalDigits(_ number: Int) -> SplitNumber {
            return SplitNumber(preDecimalDigits: preDecimalDigits + [number], postDecimalDigits: postDecimalDigits)
        }
        
        func addingNumberToPostDecimalDigits(_ number: Int) -> SplitNumber {
            return SplitNumber(preDecimalDigits: preDecimalDigits, postDecimalDigits: postDecimalDigits + [number])
        }
        
    }
    
}

fileprivate struct NumberFieldKey: View {
    
    private static let numberFormatter: NumberFormatter = NumberFormatter()
    
    let key: Key
    let action: (Key) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.key)
        }) {
            Text(textValue(for: key))
                .font(Font.largeTitle.monospacedDigit())
                .frame(minWidth: 80, minHeight: 80, alignment: .center)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(Circle())
        }.buttonStyle(PlainButtonStyle())
    }
    
    private func textValue(for key: Key) -> String {
        switch key {
        case .zero:
            return "0"
        case .one:
            return "1"
        case .two:
            return "2"
        case .three:
            return "3"
        case .four:
            return "4"
        case .five:
            return "5"
        case .six:
            return "6"
        case .seven:
            return "7"
        case .eight:
            return "8"
        case .nine:
            return "9"
        case .decimalPoint:
            return Self.numberFormatter.decimalSeparator ?? "."
        case .clear:
            return "C"
        }
    }
    
}

//MARK: - Models

extension NumberFieldKey {
    
    enum Key {
        
        case zero
        case one
        case two
        case three
        case four
        case five
        case six
        case seven
        case eight
        case nine
        case decimalPoint
        case clear
        
    }
    
    
}

