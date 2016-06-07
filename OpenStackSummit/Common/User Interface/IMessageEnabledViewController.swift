//
//  IMessageEnabledViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol MessageEnabledViewController { }

extension MessageEnabledViewController {
    func showInfoMessage(title: String, message: String) {
        SweetAlert().showAlert(title, subTitle: message, style: AlertStyle.Warning)
    }
    func showErrorMessage(error: NSError) {
        var message = error.localizedDescription
        message += "\n\nDomain: \(error.domain)\nCode: \(error.code)"
        SweetAlert().showAlert("Something failed", subTitle: message, style: AlertStyle.Error)
    }
}
