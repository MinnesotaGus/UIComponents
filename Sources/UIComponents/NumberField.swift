//
//  NumberField.swift
//  
//
//  Created by Jordan Gustafson on 6/9/21.
//

import SwiftUI

public typealias NumberFieldUnit = Identifiable & Hashable & UserFacingStringRepresentable

/// A field for displaying and editing a number
public struct NumberField<Unit: NumberFieldUnit>: View {
    
    private let number: Binding<Double>
    private let passiveDescriptionText: String?
    private let activeDescriptionText: String?
    private let selectedUnit: Binding<Unit>
    private let unitOptions: [Unit]
    
    @State private var isEditingNumber: Bool = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let passiveDescriptionText = passiveDescriptionText {
                Text(passiveDescriptionText)
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
            NumberEntryView(number: number, descriptionText: activeDescriptionText) {
                self.isEditingNumber = false
            }
        }
    }
    
    public init(number: Binding<Double>, passiveDescriptionText: String?, activeDescriptionText: String?, selectedUnit: Binding<Unit>, unitOptions: [Unit]) {
        self.number = number
        self.passiveDescriptionText = passiveDescriptionText
        self.activeDescriptionText = activeDescriptionText
        self.selectedUnit = selectedUnit
        self.unitOptions = unitOptions
    }
    
    private func numberString() -> String {
        let splitNumber = NumberEntryViewModel.SplitNumber(number: number.wrappedValue)
        return Formatter.formattedNumber(fromNumber: number.wrappedValue, withMaximumFractionalDigits: splitNumber.fractionalDigits.count)
    }
}

//MARK: Default Init

extension NumberField where Unit == NeverUnit {
    
    public init(number: Binding<Double>, passiveDescriptionText: String?, activeDescriptionText: String?) {
        self.init(number: number, passiveDescriptionText: passiveDescriptionText, activeDescriptionText: activeDescriptionText, selectedUnit: .constant(.none), unitOptions: [])
    }
    
}

//MARK: - Formatter

fileprivate final class Formatter {
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        return formatter
    }()
    
    static func formattedNumber(fromNumber number: Double, withMaximumFractionalDigits maximumFractionalDigits: Int) -> String {
        numberFormatter.maximumFractionDigits = maximumFractionalDigits
        return numberFormatter.string(from: NSNumber(value: number)) ?? String(describing: number)
    }
}

//MARK: - Previews

struct NumberField_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            Group {
                NumberFieldPreview()
            }
            
            Group {
                NumberFieldPreview()
            }.preferredColorScheme(.dark)
        }
    }
    
    struct NumberFieldPreview: View {

        @State var number: Double = 36.0

        var body: some View {
            NumberField(number: $number, passiveDescriptionText: "Bean Mass", activeDescriptionText: "Bean Mass (grams)")
                .padding()
        }

    }
    
}
