//
//  DocumentPicker.swift
//  
//
//  Created by Jordan Gustafson on 4/12/20.
//

import SwiftUI

struct DocumentPicker: UIViewControllerRepresentable {
    
    let fileURL: URL
    let delegate: UIDocumentPickerDelegate?
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let pickerViewController = UIDocumentPickerViewController(url: fileURL, in: .moveToService)
        pickerViewController.delegate = delegate
        return pickerViewController
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // nothing to do here
    }
    
}

