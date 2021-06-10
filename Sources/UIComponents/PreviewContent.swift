//
//  File.swift
//  
//
//  Created by Jordan Gustafson on 6/9/21.
//

import Foundation

/// Internal container for models used across various previews
struct PreviewContent {
    
    enum SelectableMassUnit: NumberFieldUnit {
        case ounces
        case grams
        
        var id: Self { self }
        
        var userFacingString: String {
            String(describing: self)
        }
        
        var unit: UnitMass {
            switch self {
            case .ounces:
                return UnitMass.ounces
            case .grams:
                return UnitMass.grams
            }
        }
    }
    
}
