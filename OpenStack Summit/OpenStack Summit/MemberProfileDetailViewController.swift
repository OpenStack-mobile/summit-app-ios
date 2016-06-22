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

final class MemberProfileDetailViewController: UIViewController, ShowActivityIndicatorProtocol, IndicatorInfoProvider {
    
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
            
            let attrStr = try! NSMutableAttributedString(data: biographyHTML.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            
            let range = NSMakeRange(0, attrStr.length)
            
            attrStr.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: range)
            
            bioTextView.attributedText = attrStr
        }
    }
    
    var pictureURL: String = "" {
        
        didSet {
            
            /*
             #if DEBUG
             pictureURL = newValue.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
             #else
             pictureURL = newValue
             #endif*/
            
            if (!pictureURL.isEmpty) {
                pictureImageView.hnk_setImageFromURL(NSURL(string: pictureURL)!)
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
    
    // MARK: - Loading
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // fetch from server / cache
        loadData()
    }
    
    // MARK: - Methods
    
    /* FIXME: Not implemented in legacy codebase
    func showProfile(profile: MemberProfile) {
        
    }
    
    func didFinishFriendshipRequest() {
        
    }
    
    func handleError(error: NSError) {
        
    }*/
    
    /// Fetches the data from the server or cache. 
    private func loadData() {
        
        showActivityIndicator()
        
        switch profile {
            
        case .currentUser:
            
            if let currentMember = Store.shared.authenticatedMember {
                
                if let speakerRole = currentMember.speakerRole {
                    
                    let person = PresentationSpeaker(realmEntity: speakerRole)
                    
                    updateUI(.Value(person))
                }
                else if let attendeeRole = currentMember.attendeeRole {
                    
                    let person = SummitAttendee(realmEntity: attendeeRole)
                    
                    updateUI(.Value(person))
                }
                else {
                    
                    fatalError("Authenticated member is not a speaker nor an attendee")
                }
            }
            
        case let .speaker(identifier):
            
            // load speaker from cache
            if let realmEntity = RealmPresentationSpeaker.find(identifier, realm: Store.shared.realm) {
                
                let speaker = PresentationSpeaker(realmEntity: realmEntity)
                
                updateUI(.Value(speaker))
                
            } else {
                
                updateUI(.Error(Error.getSpeakerProfile))
            }
            
        case let .attendee(identifier):
            
            // fetch attendee from server
            Store.shared.attendee(identifier) { (response) in
                
                switch response {
                    
                case let .Error(error): self.updateUI(.Error(error))
                case let .Value(value): self.updateUI(.Value(value))
                }
            }
        }
    }
    
    private func updateUI(value: ErrorValue<Person>) {
        
        defer { hideActivityIndicator() }
        
        switch value {
            
        case let .Error(error):
            
            showErrorAlert((error as NSError).localizedDescription)
            
        case let .Value(person):
            
            self.name = person.name
            self.personTitle = person.title
            self.pictureURL = person.pictureURL
            self.email = person.email
            self.twitter = person.twitter
            self.irc = person.irc
            self.biographyHTML = person.biography
            
            // FIXME: Setting location in UI, but not in DTO or deserializer
            // self.viewController.location =
        }
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Profile")
    }
}