//
//  MemberProfileViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftSpinner

@objc
public protocol IMemberProfileViewController {
    var name: String! { get set }
    var personTitle: String! { get set }
    
    func showProfile(profile: MemberProfileDTO)
    func didFinishFriendshipRequest()
    func handlerError(error: NSError)
    func showActivityIndicator()
    func hideActivityIndicator()
}

class MemberProfileViewController: UIViewController, IMemberProfileViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var name: String!{
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    var personTitle: String!{
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var presenter: IMemberProfilePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func showActivityIndicator() {
        SwiftSpinner.showWithDelay(0.5, title: "Please wait...")
    }
    
    func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
    
}
