//
//  DocumentPicker.swift
//  
//
//  Created by Jordan Gustafson on 4/12/20.
//

import SwiftUI

public struct DocumentPicker: UIViewControllerRepresentable {
    
    public let fileURL: URL
    public let delegate: UIDocumentPickerDelegate?
    
    public init(fileURL: URL, delegate: UIDocumentPickerDelegate) {
        self.fileURL = fileURL
        self.delegate = delegate
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let pickerViewController = UIDocumentPickerViewController(url: fileURL, in: .moveToService)
        pickerViewController.delegate = delegate
        return pickerViewController
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // nothing to do here
    }
    
}

