//
//  DoubleTextField.swift
//  Beans
//
//  Created by Jordan Gustafson on 2/22/20.
//  Copyright © 2020 Jordan Gustafson. All rights reserved.
//

import SwiftUI

//MARK: - Parse and format Double strings with remembered precision
public class DoublePrecision {
    
    private static let validCharSet = CharacterSet(charactersIn: "1234567890.")
    
    var integerDigits : Int = -2
    var fractionDigits : Int = -2
    var defaultFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.alwaysShowsDecimalSeparator = false
        formatter.maximumFractionDigits = 10
        return formatter
    }()
    
    func parseDouble(_ text: String) -> Double? {
        if text.rangeOfCharacter(from: Self.validCharSet.inverted) != nil {
            return nil
        }
        if text.isEmpty {
            integerDigits = -1
            fractionDigits = -1
            return 0
        }
        if let value = Double(text) {
            let substring = text.split(separator: Character("."),
                                       maxSplits: 2,
                                       omittingEmptySubsequences: false)
            switch substring.count {
            case 1:
                integerDigits = substring[0].count
                fractionDigits = -1
                return value
            case 2:
                integerDigits = substring[0].count
                fractionDigits = substring[1].count
                return value
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    func formatDouble(_ value: Double) -> String {
        if integerDigits == -2 && fractionDigits == -2 {
            let formatter = NumberFormatter()
            formatter.minimumIntegerDigits = 0
            formatter.alwaysShowsDecimalSeparator = false
            formatter.maximumFractionDigits = 10
            let result = formatter.string(from: value as NSNumber)!
            return result
        }
        if integerDigits == -1 && fractionDigits == -1 {
            return ""
        }
        if value == Double.zero && integerDigits == 0 && fractionDigits == 0 {
            return "."
        }
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = integerDigits
        formatter.maximumIntegerDigits = integerDigits
        if fractionDigits >= 0 {
            formatter.alwaysShowsDecimalSeparator = true
            formatter.minimumFractionDigits = fractionDigits
            formatter.maximumFractionDigits = fractionDigits
        } else {
            formatter.alwaysShowsDecimalSeparator = false
            formatter.maximumFractionDigits = 0
        }
        return formatter.string(from: value as NSNumber)!
    }
    
    convenience init(using: NumberFormatter) {
        self.init()
        defaultFormatter = using
    }
    
}

//MARK: - Double Text Field with allowed external precision
public struct DoubleTextField: View {
    
    @ObservedObject private var viewModel: DoubleTextModel
    private let placeHolder: String
    
    public var body: some View {
        TextField(placeHolder, text: $viewModel.text)
            .keyboardType(.decimalPad)
    }
    
    public init(_ placeHolder: String = "", value: Binding<Double>, precision: DoublePrecision) {
        self.placeHolder = placeHolder
        self.viewModel = DoubleTextModel(value: value, precision: precision)
    }
    
    public init(_ placeHolder: String = "", value: Binding<Double>) {
        self.init(placeHolder, value: value, precision: DoublePrecision())
    }
    
}

fileprivate class DoubleTextModel: ObservableObject {
    
    var valueBinding: Binding<Double>
    var precision: DoublePrecision
    
    @Published var text: String {
        didSet{
            if self.text != oldValue {
                if let value = self.precision.parseDouble(self.text) {
                    if value != self.valueBinding.wrappedValue {
                        self.valueBinding.wrappedValue = value
                    }
                } else {
                    self.text = oldValue
                }
            }
        }
    }
    
    init(value: Binding<Double>, precision: DoublePrecision) {
        valueBinding = value
        self.precision = precision
        text = precision.formatDouble(value.wrappedValue)
    }
    
}

