//
//  NumberField.swift
//  
//
//  Created by Jordan Gustafson on 6/19/20.
//

import SwiftUI

/// A field for displaying and editing a number
public struct NumberField: View {

    let number: Binding<Double>
    let descriptionText: String?

    @State private var isEditingNumber: Bool = false

    public var body: some View {
        VStack(alignment: .leading) {
            descriptionText.flatMap { text in
                Text(text)
                    .id("Header")
                    .font(.caption)
                    .animation(.easeInOut)
                    .transition(.opacity)
            }
            Text("\(number.wrappedValue)")
                .font(.body)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                .background(Color(UIColor.systemBackground))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(UIColor.secondaryLabel), lineWidth: 1))
        }.onTapGesture {
            withAnimation {
               self.isEditingNumber = true
            }
        }.modalLink(isPresented: $isEditingNumber, transition: .popUp) {
            NumberEntryView(number: self.number, descriptionText: self.descriptionText) {
                withAnimation {
                    self.isEditingNumber = false
                }
            }
        }
    }

    public init(number: Binding<Double>, descriptionText: String?) {
        self.number = number
        self.descriptionText = descriptionText
    }

}

/// A view that can be used to enter/edit a number
public struct NumberEntryView: View {
    
    @ObservedObject private var viewModel: NumberEntryViewModel
    
    public var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .center, spacing: 0.0) {
                self.numberDisplayRow()
                self.keyRow(with: [.seven, .eight, .nine])
                self.keyRow(with: [.four, .five, .six])
                self.keyRow(with: [.one, .two, .three])
                self.keyRow(with: [.decimalPoint, .zero, .clear])
                self.enterRow()
            }
            .frame(width: self.containerWidth(for: proxy))
            .fixedSize()
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    public init(number: Binding<Double>, descriptionText: String?, closeTappedAction: (() -> Void)?) {
        self.viewModel = NumberEntryViewModel(number: number, descriptionText: descriptionText, closeTappedAction: closeTappedAction)
    }

    private func numberDisplayRow() -> some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing) {
                viewModel.descriptionText.flatMap { text in
                    Text(text)
                        .font(.headline)
                        .multilineTextAlignment(.trailing)
                }
                Text(self.viewModel.displayNumber)
                    .font(Font.largeTitle.monospacedDigit())
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
            }.padding(Edge.Set(arrayLiteral: [.leading, .top, .trailing]), 8)
        }
    }
    
    private func keyRow(with keys: [NumberEntryKeyView.Key]) -> some View {
        VStack(spacing: 0) {
            Color.gray.frame(height: 1)
            HStack(spacing: 0) {
                ForEach(0..<keys.count) { index in
                    HStack(spacing: 0) {
                        NumberEntryKeyView(key: keys[index]) { key in
                            self.viewModel.tapped(key: key)
                        }
                        if index != (keys.count - 1) {
                            Color.gray.frame(width: 1)
                        }
                    }
                }
            }
        }
    }
    
    private func enterRow() -> some View {
        VStack(spacing: 0) {
            Color.gray.frame(height: 1)
            Button(action: {
                self.viewModel.closeTapped()
            }) {
                Text("Enter")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemBackground))
            }.buttonStyle(PlainButtonStyle())
        }
    }

    /// Returns the width for `NumberEntryView` based on the available space
    /// - Parameter proxy: The proxy for the available space
    private func containerWidth(for proxy: GeometryProxy) -> CGFloat {
        if (proxy.size.width) > 256 {
            return 256
        } else {
            return proxy.size.width
        }
    }
    
}

/// View Model for the `NumberEntryView`
fileprivate class NumberEntryViewModel: ObservableObject {
    
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        return formatter
    }()
    
    let descriptionText: String?
    let closeTappedAction: (() -> Void)?
    
    @Published var displayNumber: String = ""
    
    private let number: Binding<Double>
    
    private var activeDigitType: DigitType
    
    private var splitNumber: SplitNumber {
        didSet {
            updateNumber()
        }
    }
    
    init(number: Binding<Double>, descriptionText: String?, closeTappedAction: (() -> Void)?) {
        self.number = number
        self.descriptionText = descriptionText
        self.closeTappedAction = closeTappedAction
        let splitNumber = SplitNumber(number: number.wrappedValue)
        self.splitNumber = splitNumber
        if splitNumber.hasFractionalDigits {
            activeDigitType = .fractional
        } else {
            activeDigitType = .integer
        }
        
        setDisplayNumber(for: number.wrappedValue, activeDigitType: activeDigitType)
    }
    
    /// Call this method when a `Key` button is tapped
    /// - Parameter key: The `Key` that was tapped
    func tapped(key: NumberEntryKeyView.Key) {
        switch key {
        case .zero:
            numberTapped(0)
        case .one:
            numberTapped(1)
        case .two:
            numberTapped(2)
        case .three:
            numberTapped(3)
        case .four:
            numberTapped(4)
        case .five:
            numberTapped(5)
        case .six:
            numberTapped(6)
        case .seven:
            numberTapped(7)
        case .eight:
            numberTapped(8)
        case .nine:
            numberTapped(9)
        case .decimalPoint:
            if splitNumber.integerDigits.isEmpty {
                splitNumber = splitNumber.with(updatedIntegerDigits: [])
            }
            activeDigitType = .fractional
            updateNumber()
        case .clear:
            //They hit clear, so let's clear out both the interger and the fractional digits
            splitNumber = SplitNumber(integerDigits: [], fractionalDigits: [])
        }
    }
    
    /// Call this when the close button is tapped
    func closeTapped() {
        closeTappedAction?()
    }
    
    /// Updates the split number with the newly added number
    /// - Parameter number: The number to update the split number with
    private func numberTapped(_ number: Int) {
        switch activeDigitType {
        case .integer:
            if splitNumber.integerDigits.count == 1 && splitNumber.integerDigits[0] == 0 {
                splitNumber = splitNumber.with(updatedIntegerDigits: [])
            }
            splitNumber = splitNumber.addingNumberToIntegerDigits(number)
        case .fractional:
            if splitNumber.fractionalDigits.count == 1 && splitNumber.fractionalDigits[0] == 0 {
                splitNumber = splitNumber.with(updatedFractionalDigits: [])
            }
            splitNumber = splitNumber.addingNumberToFractionalDigits(number)
        }
    }
    
    /// Call this when the state changes to calculate a new value for the number
    private func updateNumber() {
        let newNumber = splitNumber.number
        if number.wrappedValue != newNumber {
            number.wrappedValue = newNumber
        }
        
        setDisplayNumber(for: newNumber, activeDigitType: activeDigitType)
    }
    
    /// Sets the `displayNumber` with the given number and active digit type
    /// - Parameters:
    ///   - number: The number to set
    ///   - activeDigitType: The type of digit that is currently active
    private func setDisplayNumber(for number: Double, activeDigitType: DigitType) {
        Self.numberFormatter.maximumFractionDigits = splitNumber.fractionalDigits.count
        let formattedNumber = Self.numberFormatter.string(from: NSNumber(value: number)) ?? "0"
        if !formattedNumber.contains(".") && activeDigitType == .fractional {
            displayNumber = formattedNumber + "."
        } else {
            displayNumber = formattedNumber
        }
    }
    
}

//MARK: - ViewModel Models

extension NumberEntryViewModel {
    
    /// Represents a number split into it's integer and fractional digits
    struct SplitNumber {
        
        /// The digits before the decimal point
        let integerDigits: [Int]
        /// The digits after the decimal point
        let fractionalDigits: [Int]
        
        /// Returns the number made up of the integer and fractional digits
        var number: Double {
            /// Calculate the value of the integer digits
            var integerDigitsValue: Double = 0.0
            let integerDigitsCount = integerDigits.count
            if integerDigitsCount > 0 {
                // Loop through all the integer digits
                for i in 0...(integerDigitsCount - 1) {
                    // Calculate the power of ten for the digit based on it's position
                    let powerOfTen = pow(10, Double(integerDigitsCount - i - 1))
                    // Add the digit times its' power of ten to the running value
                    integerDigitsValue += Double(integerDigits[i]) * powerOfTen
                }
            }
            
            /// Calculate the value of the fractional digits
            var fractionalDigitsValue: Double = 0.0
            let fractionalDigitsCount = fractionalDigits.count
            if fractionalDigitsCount > 0 {
                // Loop through all the fractional digits
                for i in 0...(fractionalDigitsCount - 1) {
                    // Loop through all the integer digits
                    let powerOfTen = pow(10, Double(i + 1))
                    // Add the digit divided by its' power of ten to the running value
                    fractionalDigitsValue += Double(fractionalDigits[i]) / powerOfTen
                }
            }
            
            return integerDigitsValue + fractionalDigitsValue
        }
        
        /// Returns with whether or not the number has any integer digits with a non-zero value
        var hasIntegerDigits: Bool {
            return !integerDigits.isEmpty && integerDigits.last != 0
        }
        
        /// Returns with whether or not the number has any fractional digits with a non-zero value
        var hasFractionalDigits: Bool {
            return !fractionalDigits.isEmpty && fractionalDigits.first != 0
        }
        
        /// Intializes a `SplitNumber` with the given number
        /// - Parameter number: The number to generate the `SplitNumber` for
        init(number: Double) {
            /// Convert it to a `String `
            let numberString = String(number)
            /// Split it on the decimal point
            let separated = numberString.split(separator: ".")
            
            /// Grab the integer digits, they should be first in the array
            if let integerDigitsString = separated.first, let integerDigitsValue = Int(String(integerDigitsString)) {
                integerDigits = String(describing: integerDigitsValue).compactMap { Int(String($0)) }
            } else {
                integerDigits = []
            }
            
            /// Check to see fi there are fractional digits, if there are grab them
            if separated.count > 1, let trailingRounded = Int(String(separated[1])) {
                let trailingPlaced = String(describing: trailingRounded).compactMap { Int(String($0)) }
                fractionalDigits = trailingPlaced
            } else {
                fractionalDigits = []
            }
        }
        
        /// Intializes a `SplitNumber` with the given integer and fractional digits
        /// - Parameters:
        ///   - integerDigits: The digits before the decimal point
        ///   - fractionalDigits: The digits after the decimal point
        init(integerDigits: [Int], fractionalDigits: [Int]) {
            self.integerDigits = integerDigits
            self.fractionalDigits = fractionalDigits
        }
        
        /// Returns a new `SplitNumber` with updated integer digits
        func with(updatedIntegerDigits: [Int]) -> SplitNumber {
            return SplitNumber(integerDigits: updatedIntegerDigits, fractionalDigits: fractionalDigits)
        }
        
        /// Returns a new `SplitNumber` with updated fractional digits
        func with(updatedFractionalDigits: [Int]) -> SplitNumber {
            return SplitNumber(integerDigits: integerDigits, fractionalDigits: updatedFractionalDigits)
        }
        
        /// Returns a new `SplitNumber` with  the given number added to the integer digits
        func addingNumberToIntegerDigits(_ number: Int) -> SplitNumber {
            return SplitNumber(integerDigits: integerDigits + [number], fractionalDigits: fractionalDigits)
        }
        
        /// Returns a new `SplitNumber` with  the given number added to the fractional digits
        func addingNumberToFractionalDigits(_ number: Int) -> SplitNumber {
            return SplitNumber(integerDigits: integerDigits, fractionalDigits: fractionalDigits + [number])
        }
        
    }
    
    enum DigitType {
        case integer
        case fractional
    }
    
}

/// A View for an individual key in the `NumberEntryView`
fileprivate struct NumberEntryKeyView: View {
    
    private static let numberFormatter: NumberFormatter = NumberFormatter()
    
    let key: Key
    let action: (Key) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.key)
        }) {
            Text(textValue(for: key))
                .font(Font.largeTitle.monospacedDigit())
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .accessibility(label: Text(self.accessibilityLabel(for: key)))
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
    
    private func accessibilityLabel(for key: Key) -> String {
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
            return "Decimal Point"
        case .clear:
            return "Clear"
        }
    }
    
}

//MARK: - Models

extension NumberEntryKeyView {
    
    /// Represents the different key types that can be used in the `NumberEntryView`
    enum Key: Hashable {
        
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

