//
//  IMessageEnabledViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

protocol MessageEnabledViewController: class {

    func showInfoMessage(title: String, message: String)
    
    func showErrorMessage(error: ErrorType, fileName: String, lineNumber: Int)
}

#if os(iOS)

extension MessageEnabledViewController {
    
    func showInfoMessage(title: String, message: String) {
        SweetAlert().showAlert(title, subTitle: message, style: AlertStyle.Warning)
    }
    
    func showErrorMessage(error: ErrorType,
                          fileName: String = #file,
                          lineNumber: Int = #line) {
        
        let nsError = (error as NSError)
        var message = nsError.localizedDescription
        message += "\n\nDomain: \(nsError.domain)\nCode: \(nsError.code)"
        SweetAlert().showAlert("Something failed", subTitle: message, style: AlertStyle.Error)
        
        print("Error at \(fileName):\(lineNumber)\n\(error)")
    }
}

#elseif os(tvOS)

extension MessageEnabledViewController {
    
    func showInfoMessage(title: String, message: String) {
        
        guard let viewController = self as? UIViewController
            else { fatalError("Not a view controller") }
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Default, handler: { (UIAlertAction) -> Void in
            
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showErrorMessage(error: ErrorType,
                          fileName: String = #file,
                          lineNumber: Int = #line) {
        
        guard let viewController = self as? UIViewController
            else { fatalError("Not a view controller") }
        
        let nsError = (error as NSError)
        let message = nsError.localizedDescription
        
        print("Error at \(fileName):\(lineNumber)\n\(error)")
        
        viewController.showErrorAlert(message)
    }
}
    
#elseif os(OSX)
    
extension MessageEnabledViewController {

    func showInfoMessage(title: String, message: String) {
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .Informational
        alert.runModal()
    }
    
    func showErrorMessage(error: ErrorType,
                          fileName: String = #file,
                          lineNumber: Int = #line) {
        
        NSApp.presentError(error as NSError)
        
        print("Error at \(fileName):\(lineNumber)\n\(error)")
    }
}
    
#endif
