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
        SweetAlert().showAlert("Something failed", subTitle: error.domain, style: AlertStyle.Error)
    }
}
