//
//  MemberOrderConfirmViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import SwiftSpinner

@objc
protocol IMemberOrderConfirmViewController: IMessageEnabledViewController{
    func showActivityIndicator()
    func hideActivityIndicator()
}

class MemberOrderConfirmViewController: BaseViewController, IMemberOrderConfirmViewController, UITextFieldDelegate {
    
    @IBOutlet weak var orderNumberText: UITextField!
    @IBOutlet weak var personPicker: UIPickerView!
    var presenter : IMemberOrderConfirmPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewLoad()
        orderNumberText.delegate = self
    }
    
    func showActivityIndicator() {
        SwiftSpinner.showWithDelay(0.5, title: "Please wait...")
    }
    
    func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        orderNumberText.resignFirstResponder()
        if !orderNumberText.text!.isEmpty {
            presenter.orderConfirm(orderNumberText.text!)            
        }
        return true
    }
}