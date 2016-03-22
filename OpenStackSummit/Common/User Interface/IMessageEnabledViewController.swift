//
//  IMessageEnabledViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMessageEnabledViewController {

}

extension IMessageEnabledViewController {
    func showErrorMessage(error: NSError) {
        var message = error.localizedDescription
        message += "\n\nDomain: \(error.domain)\nCode: \(error.code)"
        SweetAlert().showAlert("Something failed", subTitle: message, style: AlertStyle.Warning)
    }
}
