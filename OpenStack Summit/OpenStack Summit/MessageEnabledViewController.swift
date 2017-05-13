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

    func showInfoMessage(_ title: String, message: String)
    
    func showErrorMessage(_ error: Swift.Error, fileName: String, lineNumber: Int)
}

#if os(iOS) || os(tvOS)

extension MessageEnabledViewController {
    
    func showInfoMessage(_ title: String, message: String) {
        
        guard let viewController = self as? UIViewController
            else { fatalError("Not a view controller") }
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (UIAlertAction) -> () in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func showErrorMessage(_ error: Swift.Error,
                          fileName: String = #file,
                          lineNumber: Int = #line) {
        
        let nsError = (error as NSError)
        let message = nsError.localizedDescription
        
        print("Error at \(fileName):\(lineNumber)\n\(error)")
        
        if AppEnvironment == .staging {
            
            showInfoMessage(NSLocalizedString("Error", comment: "Error"), message: message)
        }
        else {
            
            showInfoMessage(NSLocalizedString("We're sorry, there was an error.", comment: "Friendly error alert title"), message: "It has been reported to our dev team.")
        }
    }
}
    
#elseif os(OSX)
    
extension MessageEnabledViewController {

    func showInfoMessage(_ title: String, message: String) {
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.runModal()
    }
    
    func showErrorMessage(_ error: Error,
                          fileName: String = #file,
                          lineNumber: Int = #line) {
        
        NSApp.presentError(error as NSError)
        
        print("Error at \(fileName):\(lineNumber)\n\(error)")
    }
}
    
#endif
