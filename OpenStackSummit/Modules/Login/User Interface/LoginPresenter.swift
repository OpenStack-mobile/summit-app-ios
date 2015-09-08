//
//  LoginPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ILoginPresenter {
    func login(userName: String, password: String)
}

public class LoginPresenter: NSObject, ILoginPresenter {
    var interactor: ILoginInteractor!
    var loginWireframe: ILoginWireframe!
    var viewController: ILoginViewController!
    
    public func login(userName: String, password: String) {
        interactor.login(userName, password: password) { member, error in
            if (error == nil) {
                self.loginWireframe.dismissLoginView()
            }
            else {
                self.viewController.handleError(error!)
            }
        }
    }
}
