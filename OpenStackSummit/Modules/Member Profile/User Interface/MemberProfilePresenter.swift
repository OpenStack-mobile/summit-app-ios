//
//  MemberProfilePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation

@objc
public protocol IMemberProfilePresenter {
    var memberId: Int { get set }
}

public class MemberProfilePresenter: NSObject, IMemberProfilePresenter {
    
    var viewController: IMemberProfileViewController!
    var interactor: IMemberProfileInteractor!
    
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