//
//  NumberField.swift
//  
//
//  Created by Jordan Gustafson on 6/19/20.
//

import Combine
import SwiftUI

/// A view that can be used to enter/edit a number
public struct NumberEntryView<Unit: NumberFieldUnit>: View {
    
    private let selectedUnit: Binding<Unit>
    private let unitOptions: [Unit]
    
    @State private var viewModel: NumberEntryViewModel
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass: UserInterfaceSizeClass?
    
    public var body: some View {
        GeometryReader { proxy in
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: spacing()) {
                    Spacer()
                    numberDisplayRow()
                    if unitOptions.count > 1 {
                        unitPickerView()
                    }
                    keyRow(with: [.seven, .eight, .nine])
                    keyRow(with: [.four, .five, .six])
                    keyRow(with: [.one, .two, .three])
                    keyRow(with: [.decimalPoint, .zero, .delete])
                    Spacer()
                }
                .background(keyInputView())
                .frame(width: self.containerWidth(for: proxy), alignment: .center)
                Spacer()
            }
        }
        .overlay(self.closeButton(), alignment: .topLeading)
        .padding()
    }
    
    init(number: Binding<Double>, descriptionText: String?, selectedUnit: Binding<Unit>, unitOptions: [Unit], closeTappedAction: (() -> Void)?) {
        self._viewModel = State(wrappedValue: NumberEntryViewModel(number: number, descriptionText: descriptionText, closeTappedAction: closeTappedAction))
        self.selectedUnit = selectedUnit
        self.unitOptions = unitOptions
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
                Text(viewModel.displayNumber)
                    .font(Font.largeTitle.monospacedDigit())
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
            }
        }
        .roundedPaddedBackground()
    }
    
    private func unitPickerView() -> some View {
        Picker(selection: selectedUnit, label: Text("Unit")) {
            ForEach(unitOptions) { option in
                Text(option.userFacingString)
            }
        }.pickerStyle(SegmentedPickerStyle())
    }
    
    private func keyRow(with keys: [NumberEntryKeyView.Key]) -> some View {
        HStack(spacing: spacing()) {
            ForEach(keys, id: \.self) { key in
                NumberEntryKeyView(key: key) { key in
                    self.viewModel.tapped(key: key)
                }
            }
        }
    }
    
    private func closeButton() -> some View {
        viewModel.closeTappedAction.flatMap { _ in
            Button(action: {
                self.viewModel.closeTapped()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .renderingMode(.template)
                    .font(.largeTitle)
                    .accentColor(Color(UIColor.gray))
                    .accessibility(label: Text("Close"))
            }
        }
    }
    
    private func keyInputView() -> some View {
        KeyInputView { keyEvent in
            switch keyEvent {
            case let .pressed(key):
                self.viewModel.handleHardwareKeyTap(key: key)
            case .released:
                break
            }
        }
    }
    
    //MARK: - UI Values
    
    /// Returns the spacing between the keys
    private func spacing() -> CGFloat {
        switch verticalSizeClass {
        case .compact:
            return 8
        case .regular:
            return 8
        case nil:
            return 8
        @unknown default:
            return 8
        }
    }
    
    /// Returns the width for `NumberEntryView` based on the available space
    /// - Parameter proxy: The proxy for the available space
    private func containerWidth(for proxy: GeometryProxy) -> CGFloat {
        if (proxy.size.width + (spacing() * 2.0)) > 256 {
            return 256
        } else {
            return proxy.size.width
        }
    }
}

//MARK: - Default Init

extension NumberEntryView where Unit == NeverUnit {
    
    public init(number: Binding<Double>, descriptionText: String?, closeTappedAction: (() -> Void)?) {
        self.init(number: number, descriptionText: descriptionText,  selectedUnit: .constant(.none), unitOptions: [], closeTappedAction: closeTappedAction)
    }
    
}

public enum NeverUnit: Identifiable, Hashable, CaseIterable, UserFacingStringRepresentable {
    case none
    
    public var id: Self { self }
    
    public var userFacingString: String { String(describing: self) }
}

//MARK: - View Model

/// View Model for the `NumberEntryView`
struct NumberEntryViewModel {
    
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        return formatter
    }()
    
    let descriptionText: String?
    let closeTappedAction: (() -> Void)?
    
    var displayNumber: String {
        Self.numberFormatter.minimumFractionDigits = splitNumber.fractionalDigits.count
        Self.numberFormatter.maximumFractionDigits = splitNumber.fractionalDigits.count
        let formattedNumber = Self.numberFormatter.string(from: NSNumber(value: splitNumber.number)) ?? "0"
        if activeDigitType == .fractional && splitNumber.fractionalDigits.isEmpty {
            return formattedNumber + "."
        } else {
            return formattedNumber
        }
    }
    
    private let number: Binding<Double>
    
    private var activeDigitType: DigitType
    
    internal var splitNumber: SplitNumber
    
    init(number: Binding<Double>, descriptionText: String?, closeTappedAction: (() -> Void)?) {
        self.number = number
        self.descriptionText = descriptionText
        self.closeTappedAction = closeTappedAction
        let splitNumber = SplitNumber(number: number.wrappedValue)
        self.splitNumber = splitNumber
        if splitNumber.hasNonZeroFractionalDigits {
            activeDigitType = .fractional
        } else {
            activeDigitType = .integer
        }
    }
    
    /// Call this method when a `Key` button is tapped
    /// - Parameter key: The `Key` that was tapped
    fileprivate mutating func tapped(key: NumberEntryKeyView.Key) {
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
            activeDigitType = .fractional
        case .delete:
            if splitNumber.fractionalDigits.isEmpty {
                activeDigitType = .integer
            }
            splitNumber = splitNumber.deletingLastDigit()
        }
        updateNumber()
    }
    
    /// Call this when the close button is tapped
    func closeTapped() {
        closeTappedAction?()
    }
    
    /// Updates the split number with the newly added number
    /// - Parameter number: The number to update the split number with
    mutating private func numberTapped(_ number: Int) {
        switch activeDigitType {
        case .integer:
            splitNumber = splitNumber.addingNumberToIntegerDigits(number)
        case .fractional:
            splitNumber = splitNumber.addingNumberToFractionalDigits(number)
        }
    }
    
    /// Call this when the state changes to calculate a new value for the number
    mutating private func updateNumber() {
        let newNumber = splitNumber.number
        number.wrappedValue = newNumber
    }
    
    mutating func handleHardwareKeyTap(key: UIKey) {
        print(key.characters)
        switch key.keyCode {
        case .keypad0, .keyboard0:
            tapped(key: .zero)
        case .keypad1, .keyboard1:
            tapped(key: .one)
        case .keypad2, .keyboard2:
            tapped(key: .two)
        case .keypad3, .keyboard3:
            tapped(key: .three)
        case .keypad4, .keyboard4:
            tapped(key: .four)
        case .keypad5, .keyboard5:
            tapped(key: .five)
        case .keypad6, .keyboard6:
            tapped(key: .six)
        case .keypad7, .keyboard7:
            tapped(key: .seven)
        case .keypad8, .keyboard8:
            tapped(key: .eight)
        case .keypad9, .keyboard9:
            tapped(key: .nine)
        case .keypadPeriod,
             .keyboardPeriod,
             .keypadComma,
             .keyboardComma:
            tapped(key: .decimalPoint)
        case .keyboardDeleteOrBackspace:
            tapped(key: .delete)
        default:
            break
        }
    }
    
}

//MARK: - ViewModel Models

extension NumberEntryViewModel {
    
    /// Represents a number split into it's integer and fractional digits
    public struct SplitNumber {
        
        /// The digits before the decimal point
        public let integerDigits: [Int]
        /// The digits after the decimal point
        public let fractionalDigits: [Int]
        
        /// Returns the number made up of the integer and fractional digits
        public var number: Double {
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
        public var hasNonZeroIntegerDigits: Bool {
            return !integerDigits.isEmpty && integerDigits.last != 0
        }
        
        /// Returns with whether or not the number has any fractional digits with a non-zero value
        public var hasNonZeroFractionalDigits: Bool {
            return !fractionalDigits.isEmpty && fractionalDigits.first != 0
        }
        
        /// Intializes a `SplitNumber` with the given number
        /// - Parameter number: The number to generate the `SplitNumber` for
        public init(number: Double) {
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
                if trailingPlaced != [0] {
                    fractionalDigits = trailingPlaced
                } else {
                    fractionalDigits = []
                }
            } else {
                fractionalDigits = []
            }
        }
        
        /// Intializes a `SplitNumber` with the given integer and fractional digits
        /// - Parameters:
        ///   - integerDigits: The digits before the decimal point
        ///   - fractionalDigits: The digits after the decimal point
        public init(integerDigits: [Int], fractionalDigits: [Int]) {
            self.integerDigits = integerDigits
            self.fractionalDigits = fractionalDigits
        }
        
        /// Returns a new `SplitNumber` with  the given number added to the integer digits
        public func addingNumberToIntegerDigits(_ number: Int) -> SplitNumber {
            let fixed = integerDigits != [0] ? integerDigits : []
            return SplitNumber(integerDigits: fixed + [number], fractionalDigits: fractionalDigits)
        }
        
        /// Returns a new `SplitNumber` with  the given number added to the fractional digits
        public func addingNumberToFractionalDigits(_ number: Int) -> SplitNumber {
            let fixedInteger = integerDigits == [] ? [0] : integerDigits
            return SplitNumber(integerDigits: fixedInteger, fractionalDigits: fractionalDigits + [number])
        }
        
        /// Returns a new `SplitNumber` with the last digit deleted
        public func deletingLastDigit() -> SplitNumber {
            if !fractionalDigits.isEmpty {
                return SplitNumber(integerDigits: integerDigits, fractionalDigits: fractionalDigits.dropLast())
            } else if !integerDigits.isEmpty {
                return SplitNumber(integerDigits: integerDigits.dropLast(), fractionalDigits: [])
            } else {
                return SplitNumber(integerDigits: [], fractionalDigits: [])
            }
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
            action(key)
        }) {
            keyIconView(for: key)
                .frame(maxWidth: 80, maxHeight: 80, alignment: .center)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(Circle())
                .accessibility(label: Text(accessibilityLabel(for: key)))
        }.buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func keyIconView(for key: Key) -> some View {
        switch key {
        case .zero,
             .one,
             .two,
             .three,
             .four,
             .five,
             .six,
             .seven,
             .eight,
             .nine,
             .decimalPoint:
            textView(for: key)
        case .delete:
            deleteImageView()
        }
    }
    
    private func deleteImageView() -> some View {
        Image(systemName: "delete.left")
            .font(Font.title.monospacedDigit())
    }
    
    private func textView(for key: Key) -> some View {
        Text(textValue(for: key))
            .font(Font.largeTitle.monospacedDigit())
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
        case .delete:
            return "D"
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
        case .delete:
            return "Delete"
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
        case delete
        
    }
    
}

//MARK: - Previews

struct NumberEntryView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            Group {
                Preview()
            }
            
            Group {
                Preview()
            }.preferredColorScheme(.dark)
        }
    }
    
    struct Preview: View {
        let unitOptions: [PreviewContent.SelectableMassUnit] = [.ounces, .grams]
        @State var selection: PreviewContent.SelectableMassUnit = .ounces
        @State var number: Double = 0.0
        
        var body: some View {
            NumberEntryView(number: $number, descriptionText: "Some Number", selectedUnit: $selection, unitOptions: unitOptions, closeTappedAction: nil)
        }
    }
}

