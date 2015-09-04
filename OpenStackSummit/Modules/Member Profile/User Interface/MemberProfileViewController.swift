//
//  MemberProfileViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberProfileViewController {
    func showProfile(profile: MemberProfileDTO)
    func didFinishFriendshipRequest()
    func handlerError(error: NSError)
}

class MemberProfileViewController: UIViewController, IMemberProfileViewController {
    
    var presenter: IMemberProfilePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.showMemberProfile()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showProfile(profile: MemberProfileDTO) {
        
    }
    
    func didFinishFriendshipRequest() {
        
    }
    
    func handlerError(error: NSError) {
        
    }
}
