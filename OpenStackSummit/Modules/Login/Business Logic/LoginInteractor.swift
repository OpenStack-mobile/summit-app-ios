//
//  LoginInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ILoginInteractor {
    func login(userName: String, password: String, completionBlock : (Member?, NSError?) -> Void)
}

public class LoginInteractor: NSObject {
    func login(userName: String, password: String, completionBlock : (Member?, NSError?) -> Void) {
    
    }
}
