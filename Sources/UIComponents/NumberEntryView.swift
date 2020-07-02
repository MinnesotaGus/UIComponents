//
//  NumberField.swift
//  
//
//  Created by Jordan Gustafson on 6/19/20.
//

import Combine
import SwiftUI

/// A field for displaying and editing a number
public struct NumberField: View {
    
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        return formatter
    }()
    
    private let number: Binding<Double>
    private let descriptionText: String?
    
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
            Text(numberString())
                .font(.body)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                .background(Color(UIColor.systemBackground))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(UIColor.secondaryLabel), lineWidth: 1))
        }.onTapGesture {
            self.isEditingNumber = true
        }.sheet(isPresented: $isEditingNumber) {
            NumberEntryView(number: self.number, descriptionText: self.descriptionText) {
                self.isEditingNumber = false
            }
        }
    }
    
    public init(number: Binding<Double>, descriptionText: String?) {
        self.number = number
        self.descriptionText = descriptionText
    }
    
    private func numberString() -> String {
        let splitNumber = NumberEntryViewModel.SplitNumber(number: number.wrappedValue)
        Self.numberFormatter.maximumFractionDigits = splitNumber.fractionalDigits.count
        return Self.numberFormatter.string(from: NSNumber(value: number.wrappedValue)) ?? String(describing: number.wrappedValue)
    }
    
}

/// A view that can be used to enter/edit a number
public struct NumberEntryView: View {
    
    @ObservedObject private var viewModel: NumberEntryViewModel
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    
    public var body: some View {
        GeometryReader { proxy in
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: spacing()) {
                    Spacer()
                    numberDisplayRow()
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
            }
        }
        .roundedPaddedBackground()
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
                splitNumber = splitNumber.addingNumberToIntegerDigits(0)
            }
            activeDigitType = .fractional
            updateNumber()
        case .delete:
            splitNumber = splitNumber.deletingLastDigit()
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
            splitNumber = splitNumber.addingNumberToIntegerDigits(number)
        case .fractional:
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
        if activeDigitType == .fractional && splitNumber.fractionalDigits.isEmpty {
            displayNumber = formattedNumber + "."
        } else {
            displayNumber = formattedNumber
        }
    }
    
    func handleHardwareKeyTap(key: UIKey) {
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
        
        /// Returns a new `SplitNumber` with  the given number added to the integer digits
        func addingNumberToIntegerDigits(_ number: Int) -> SplitNumber {
            return SplitNumber(integerDigits: integerDigits + [number], fractionalDigits: fractionalDigits)
        }
        
        /// Returns a new `SplitNumber` with  the given number added to the fractional digits
        func addingNumberToFractionalDigits(_ number: Int) -> SplitNumber {
            return SplitNumber(integerDigits: integerDigits, fractionalDigits: fractionalDigits + [number])
        }
        
        func deletingLastDigit() -> SplitNumber {
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
            self.action(self.key)
        }) {
            keyIconView(for: key)
                .frame(maxWidth: 80, maxHeight: 80, alignment: .center)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(Circle())
                .accessibility(label: Text(self.accessibilityLabel(for: key)))
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


struct NumberField_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            Group {
                NumberFieldPreview()
            }
            
            Group {
                NumberFieldPreview()
            }.environment(\.colorScheme, .dark)
        }
    }
    
    struct NumberFieldPreview: View {

        @State var number: Double = 0.0

        var body: some View {
            NumberField(number: $number, descriptionText: "Some number")
        }

    }
    
}

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
        
        @State var number: Double = 0.0
        
        var body: some View {
            NumberEntryView(number: $number, descriptionText: "Some Number", closeTappedAction: nil)
        }
        
    }
    
}

