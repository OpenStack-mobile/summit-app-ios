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
    var memberId: Int { get set }
}

public class MyProfilePresenter: NSObject, IMyProfilePresenter {
    
    var viewController: IMyProfileViewController!
    var interactor: IMyProfileInteractor!
    
    var internalMemberId: Int = 0
    public var memberId: Int {
        get {
            return internalMemberId
        }
        set {
            internalMemberId = newValue
            
            self.interactor.getSpeakerProfile(newValue) { speaker, error in
                if speaker != nil {
                    self.viewController.title = speaker!.name.uppercaseString
                }
            }
        }
    }
    
}