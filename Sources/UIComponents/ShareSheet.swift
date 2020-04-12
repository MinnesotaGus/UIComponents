//
//  ShareSheet.swift
//  
//
//  Created by Jordan Gustafson on 4/12/20.
//

import SwiftUI

public struct ShareSheet: UIViewControllerRepresentable {
    
    public typealias Completion = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
      
    public let activityItems: [Any]
    public let applicationActivities: [UIActivity]?
    public let excludedActivityTypes: [UIActivity.ActivityType]?
    public let completion: Completion?
    
    public init (activityItems: [Any], applicationActivities: [UIActivity]?, excludedActivityTypes: [UIActivity.ActivityType]?, completion: Completion?) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
        self.excludedActivityTypes = excludedActivityTypes
        self.completion = completion
    }
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = completion
        return controller
    }
      
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
    
}

