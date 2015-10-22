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
    var picUrl: String! { get set }
    
    func showProfile(profile: MemberProfileDTO)
    func didFinishFriendshipRequest()
    func handlerError(error: NSError)
    func showActivityIndicator()
    func hideActivityIndicator()
}

class MemberProfileViewController: UIViewController, IMemberProfileViewController {
    
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
    
    var picUrl: String! {
        get {
            return picUrlInternal
        }
        set {
            picUrlInternal = newValue
            if (!picUrlInternal.isEmpty) {
                pictureImageView.hnk_setImageFromURL(NSURL(string: picUrlInternal)!)
            }
            else {
                pictureImageView.hnk_setImageFromURL(NSURL(string: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQsKM4aXdIlZmlLHSonqBq9UsESy4WQidH3Dqa3NeeL4qgPzAq70w")!)
            }
            
            pictureImageView.layer.borderWidth = 3.0;
            pictureImageView.layer.cornerRadius = pictureImageView.frame.size.width / 2
            pictureImageView.layer.borderColor = UIColor.whiteColor().CGColor
            pictureImageView.clipsToBounds = true;
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    var presenter: IMemberProfilePresenter!
    private var picUrlInternal: String!

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
