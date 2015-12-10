//
//  MyProfilePresenter.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 12/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation

@objc
public protocol IMyProfilePresenter {
    func viewLoad(memberId: Int)
}

class MyProfilePresenter: NSObject, IMyProfilePresenter {
    
    weak var viewController: IMyProfileViewController!
    
    func viewLoad(memberId: Int) {
    }
    
}