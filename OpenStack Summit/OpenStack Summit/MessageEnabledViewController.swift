//
//  IMessageEnabledViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol MessageEnabledViewController: class {

}

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
