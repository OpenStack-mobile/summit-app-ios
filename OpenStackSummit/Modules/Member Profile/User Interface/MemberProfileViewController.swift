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
protocol IMemberProfileViewController {
    var name: String! { get set }
    var personTitle: String! { get set }
    var picUrl: String! { get set }	
    var location: String! { get set }
    var email: String! { get set }
    var twitter: String! { get set }
    var irc: String! { get set }
    var bio: String! { get set }
    
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
    
    var location: String! {
        get {
            return locationLabel.text
        }
        set {
            locationLabel.text = newValue
            if (newValue.isEmpty) {
                locationView.hidden = true
                locationViewLayoutConstraint.constant = 0
            }
            else {
                locationView.hidden = false
                locationViewLayoutConstraint.constant = 40
            }
            
            if (newValue.isEmpty && email.isEmpty && twitter == "@" && irc.isEmpty) {
                ircViewBottomLayoutConstraint.constant = 0
                bioTextViewLayoutConstraint.constant = -9
            }
            else {
                ircViewBottomLayoutConstraint.constant = -20
                bioTextViewLayoutConstraint.constant = 20
            }
        }
    }
    
    var email: String! {
        get {
            return emailLabel.text
        }
        set {
            emailLabel.text = newValue
            if (newValue.isEmpty) {
                emailView.hidden = true
                emailViewLayoutConstraint.constant = 0
            }
            else {
                emailView.hidden = false
                emailViewLayoutConstraint.constant = 40
            }
            
            if (newValue.isEmpty && location.isEmpty && twitter == "@" && irc.isEmpty) {
                ircViewBottomLayoutConstraint.constant = 0
                bioTextViewLayoutConstraint.constant = -9
            }
            else {
                ircViewBottomLayoutConstraint.constant = -20
                bioTextViewLayoutConstraint.constant = 20
            }
        }
    }
    
    var twitter: String! {
        get {
            return twitterLabel.text
        }
        set {
            twitterLabel.text = newValue.hasPrefix("@") ? newValue : "@" + newValue
            
            if (newValue.isEmpty) {
                twitterView.hidden = true
                twitterViewLayoutConstraint.constant = 0
            }
            else {
                twitterView.hidden = false
                twitterViewLayoutConstraint.constant = 40
            }
            
            if (newValue.isEmpty && location.isEmpty && email.isEmpty && irc.isEmpty) {
                ircViewBottomLayoutConstraint.constant = 0
                bioTextViewLayoutConstraint.constant = -9
            }
            else {
                ircViewBottomLayoutConstraint.constant = -20
                bioTextViewLayoutConstraint.constant = 20
            }
        }
    }
    
    var irc: String! {
        get {
            return ircLabel.text
        }
        set {
            ircLabel.text = newValue
            if (newValue.isEmpty) {
                ircView.hidden = true
                ircViewHeightLayoutConstraint.constant = 0
            }
            else {
                ircView.hidden = false
                ircViewHeightLayoutConstraint.constant = 40
            }
            
            if (newValue.isEmpty && location.isEmpty && email.isEmpty && twitter == "@") {
                ircViewBottomLayoutConstraint.constant = 0
                bioTextViewLayoutConstraint.constant = -9
            }
            else {
                ircViewBottomLayoutConstraint.constant = -20
                bioTextViewLayoutConstraint.constant = 20
            }
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
                pictureImageView.image = UIImage(named: "generic-user-avatar")
            }
            
            pictureImageView.layer.borderWidth = 0.88;
            pictureImageView.layer.borderColor = UIColor(red: 215/255, green: 226/255, blue: 235/255, alpha: 1.0).CGColor
            pictureImageView.layer.cornerRadius = pictureImageView.frame.size.width / 2
            pictureImageView.clipsToBounds = true;
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var accountsView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var twitterView: UIView!
    @IBOutlet weak var twitterViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var ircView: UIView!
    @IBOutlet weak var ircViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var ircViewBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var ircLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var bioTextViewLayoutConstraint: NSLayoutConstraint!
    
    var presenter: IMemberProfilePresenter!
    
    private var picUrlInternal: String!
    private var bioHTML: String!

    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewLoad()
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
        SwiftSpinner.show("Please wait...")
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
