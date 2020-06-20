//
//  NumberEntryView.swift
//  
//
//  Created by Jordan Gustafson on 6/19/20.
//

import SwiftUI

public struct NumberEntryView: View {
    
    @ObservedObject private var viewModel: NumberEntryViewModel
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    
    public var body: some View {
        GeometryReader { proxy in
            VStack(spacing: self.spacing()) {
                Spacer()
                self.numberDisplayRow()
                self.keyRow(with: [.seven, .eight, .nine])
                self.keyRow(with: [.four, .five, .six])
                self.keyRow(with: [.one, .two, .three])
                self.keyRow(with: [.decimalPoint, .zero, .clear])
            }
            .frame(width: self.containerWidth(for: proxy))
        }
        .overlay(self.closeButton(), alignment: .topLeading)
        .padding()
        
    }
    
    public init(number: Binding<Double>, description: String?, closeTappedAction: (() -> Void)?) {
        self.viewModel = NumberEntryViewModel(number: number, description: description, closeTappedAction: closeTappedAction)
    }

    
    private func numberDisplayRow() -> some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing) {
                viewModel.description.flatMap { text in
                    Text(text)
                        .font(.headline)
                        .multilineTextAlignment(.trailing)
                }
                Text(self.viewModel.displayNumber)
                    .font(Font.largeTitle.monospacedDigit())
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
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
            }
        }
    }
    
    //MARK: - UI Values
    
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
    
    private func containerWidth(for proxy: GeometryProxy) -> CGFloat {
        if (proxy.size.width + (spacing() * 2.0)) > 256 {
            return 256
        } else {
            return proxy.size.width
        }
    }
    
}

fileprivate class NumberEntryViewModel: ObservableObject {
    
    let description: String?
    let closeTappedAction: (() -> Void)?
    
    @Published var displayNumber: String = ""
    
    private let number: Binding<Double>
    
    private var editingPlace: EditingLocation
    
    private var splitNumber: SplitNumber {
        didSet {
            updateNumber()
        }
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        return formatter
    }()
    
    init(number: Binding<Double>, description: String?, closeTappedAction: (() -> Void)?) {
        self.number = number
        self.description = description
        self.closeTappedAction = closeTappedAction
        let splitNumber = SplitNumber(number: number.wrappedValue)
        self.splitNumber = splitNumber
        if !splitNumber.postDecimalDigits.isEmpty && splitNumber.postDecimalDigits[0] != 0 {
            editingPlace = .postDecimal
        } else {
            editingPlace = .preDecimal
        }
        
        numberFormatter.maximumFractionDigits = splitNumber.postDecimalDigits.count
        displayNumber = numberFormatter.string(from: NSNumber(value: number.wrappedValue)) ?? "0.0"
    }
    
    func tapped(key: NumberEntryKeyView.Key) {
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
            editingPlace = .postDecimal
            updateNumber()
        case .clear:
            splitNumber = SplitNumber(preDecimalDigits: [], postDecimalDigits: [])
        }
    }
    
    func closeTapped() {
        closeTappedAction?()
    }
    
    private func append(number: Int) {
        switch editingPlace {
        case .preDecimal:
            if splitNumber.preDecimalDigits.count == 1 && splitNumber.preDecimalDigits[0] == 0 {
                splitNumber = splitNumber.with(updatedPreDecimalDigits: [])
            }
            splitNumber = splitNumber.addingNumberToPreDecimalDigits(number)
        case .postDecimal:
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
        if !formattedNumber.contains(".") && editingPlace == .postDecimal {
            displayNumber = formattedNumber + "."
        } else {
            displayNumber = formattedNumber
        }
    }
    
    enum EditingLocation {
        case preDecimal
        case postDecimal
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
                .frame(maxWidth: 80, maxHeight: 80, alignment: .center)
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

extension NumberEntryKeyView {
    
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

