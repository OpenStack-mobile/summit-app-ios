//
//  MemberProfileDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/20/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Haneke
import CoreSummit

final class MemberProfileDetailViewController: UIViewController, IndicatorInfoProvider {
    
    // MARK: - IB Outlets
    
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
    
    // MARK: - Properties
    
    var profile: MemberProfileIdentifier = .currentUser
    
    var biographyHTML: String = "" {
        
        didSet {
            
            if let data = biographyHTML.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false),
                let attrStr = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
                
                let range = NSMakeRange(0, attrStr.length)
                
                attrStr.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: range)
                
                bioTextView.attributedText = attrStr
                
            } else {
                
                bioTextView.text = ""
            }
        }
    }
    
    var pictureURL: String = "" {
        
        didSet {
            
            if (!pictureURL.isEmpty) {
                
                let urlString = pictureURL.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                pictureImageView.hnk_setImageFromURL(NSURL(string: urlString)!)
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
    
    // MARK: - Accessors
    
    var name: String {
        get {
            return nameLabel.text ?? ""
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    var personTitle: String {
        get {
            return titleLabel.text ?? ""
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var location: String {
        get {
            return locationLabel.text ?? ""
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
    
    var twitter: String {
        get {
            return twitterLabel.text ?? ""
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
    
    var irc: String {
        get {
            return ircLabel.text ?? ""
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
    
    // MARK: - Loading
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // fetch from cache
        loadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 9.0, *) {
            userActivity?.resignCurrent()
        }
    }
    
    // MARK: - Methods
    
    /* FIXME: Not implemented in legacy codebase
    func showProfile(profile: MemberProfile) {
        
    }
    
    func didFinishFriendshipRequest() {
        
    }
    
    func handleError(error: NSError) {
        
    }*/
    
    /// Fetches the data from cache. 
    private func loadData() {
        
        switch profile {
            
        case .currentUser:
            
            if let currentMember = Store.shared.authenticatedMember {
                
                if let speakerRole = currentMember.speakerRole {
                    
                    let person = Speaker(managedObject: speakerRole)
                    
                    updateUI(.Value(person))
                }
                else {
                    
                    let member = Member(managedObject: currentMember)
                    
                    updateUI(.Value(member))
                }
            } else {
                
                fatalError("Cannot show current user, not logged in")
            }
            
        case let .speaker(identifier):
            
            // load speaker from cache
            if let speakerManagedObject = try! SpeakerManagedObject.find(identifier, context: Store.shared.managedObjectContext) {
                
                let speaker = Speaker(managedObject: speakerManagedObject)
                
                let summit = Summit(managedObject: speakerManagedObject.summits.first!)
                
                updateUI(.Value(speaker))
                
                // set user activity for handoff
                let userActivity = NSUserActivity(activityType: AppActivity.view.rawValue)
                userActivity.title = self.title
                userActivity.webpageURL = NSURL(string: speaker.toWebpageURL(summit))
                
                userActivity.userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.speaker.rawValue, AppActivityUserInfo.identifier.rawValue: identifier]
                
                userActivity.becomeCurrent()
                
                self.userActivity = userActivity
                
            } else {
                
                updateUI(ErrorValue<Speaker>.Error(Error.getSpeakerProfile))
            }
            
        case let .member(identifier):
            
            if let member = try! Member.find(identifier, context: Store.shared.managedObjectContext) {
                
                self.userActivity = nil
                
                updateUI(.Value(member))
                
            } else {
                
                updateUI(ErrorValue<Member>.Error(Error.getMemberProfile))
            }
        }
    }
    
    private func updateUI<T: Person>(value: ErrorValue<T>) {
        
        switch value {
            
        case let .Error(error):
            
            showErrorAlert((error as NSError).localizedDescription)
            
        case let .Value(person):
            
            self.title = person.name
            self.name = person.name
            self.personTitle = person.title ?? ""
            self.pictureURL = person.pictureURL
            self.twitter = person.twitter ?? ""
            self.irc = person.irc ?? ""
            self.biographyHTML = person.biography ?? ""
            
            // not in DTO or deserializer
            self.location = ""
            self.email = ""
        }
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Profile")
    }
}
