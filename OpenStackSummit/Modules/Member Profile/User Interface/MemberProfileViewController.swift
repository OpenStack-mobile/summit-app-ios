//
//  MemberProfileViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftSpinner
import XLPagerTabStrip

@objc
public protocol IMemberProfileViewController {
    var name: String! { get set }
    var personTitle: String! { get set }
    var picUrl: String! { get set }
    var bio: String! { get set }
    var isLoggedMemberProfile: Bool { get set }
    
    func showProfile(profile: MemberProfileDTO)
    func didFinishFriendshipRequest()
    func handlerError(error: NSError)
    func showActivityIndicator()
    func hideActivityIndicator()
}

class MemberProfileViewController: UIViewController, IMemberProfileViewController, XLPagerTabStripChildItem {
    
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

    var bio: String! {
        get {
            return bioHTML
        }
        set {
            bioHTML = newValue
            let attrStr = try! NSMutableAttributedString(data: bioHTML.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)

            let range = NSMakeRange(0, attrStr.length)
            
            attrStr.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: range)
            
            bioTextView.attributedText = attrStr
        }
    }
    
    var picUrl: String! {
        get {
            return picUrlInternal
        }
        set {
            picUrlInternal = newValue.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
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
    
    var isLoggedMemberProfile: Bool = false
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var bioTextView: UITextView!
    
    var presenter: IMemberProfilePresenter!
    private var picUrlInternal: String!
    private var bioHTML: String!

    override func viewWillAppear(animated: Bool) {
        presenter.viewLoad()
    }
    
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
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> String {
        return "Profile"
    }
}
