//
//  MemberProfilePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberProfilePresenter {
    var memberId: Int { get set }
    
    func showMemberProfile()
}

public class MemberProfilePresenter: NSObject, IMemberProfilePresenter {
    var memberProfileWireframe: IMemberProfileWireframe!
    var interactor: IMemberProfileInteractor!
    var memberProfileDTOAssembler: IMemberProfileDTOAssembler!
    public var memberId = 0
    
    public func showMemberProfile() {
        let member = interactor.getMember(memberId) { member, error in
            
            let canShowFullProfile = self.interactor.isFullProfileAllowed(member!)
        }
    }
}
