//
//  LoginWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ILoginWireframe {
    func dismissLoginView()
    func presentLoginView(parent: UIViewController)
}

public class LoginWireframe: NSObject, ILoginWireframe {
    
    var loginViewController: LoginViewController!
    
    public func dismissLoginView() {
        loginViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func presentLoginView(parent: UIViewController) {
        parent.presentViewController(loginViewController, animated: true, completion: nil)
    }
}
