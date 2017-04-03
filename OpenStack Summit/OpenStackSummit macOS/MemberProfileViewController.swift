//
//  MemberDetailViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit

final class MemberProfileViewController: NSViewController, NSSharingServicePickerDelegate, NSSharingServiceDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var shareButton: NSButton!
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var titleLabel: NSTextField!
    
    @IBOutlet private(set) weak var descriptionView: NSView!
    
    @IBOutlet private(set) weak var descriptionLabel: NSTextField!
    
    @IBOutlet private(set) weak var imageView: NSImageView!
    
    @IBOutlet private(set) weak var locationView: NSBox!
    
    @IBOutlet private(set) weak var locationLabel: NSTextField!
    
    @IBOutlet private(set) weak var twitterView: NSBox!
    
    @IBOutlet private(set) weak var twitterLabel: NSTextField!
    
    @IBOutlet private(set) weak var ircView: NSBox!
    
    @IBOutlet private(set) weak var ircLabel: NSTextField!
    
    // MARK: - Properties
    
    var profile: PersonIdentifier = .currentUser {
        
        didSet { loadData() }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.sendActionOn(.LeftMouseDown)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        userActivity?.becomeCurrent()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        userActivity?.resignCurrent()
    }
    
    override func updateUserActivityState(userActivity: NSUserActivity) {
        
        if case let .speaker(speaker) = profile {
            
            let userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.speaker.rawValue,
                            AppActivityUserInfo.identifier.rawValue: speaker]
            
            userActivity.addUserInfoEntriesFromDictionary(userInfo as [NSObject: AnyObject])
        }
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Actions
    
    @IBAction func share(sender: NSButton) {
        
        var items = [AnyObject]()
        
        items.append(self.nameLabel.stringValue ?? "")
        
        items.append(self.titleLabel.stringValue ?? "")
        
        if descriptionLabel.attributedStringValue.string.isEmpty == false {
            
            items.append(descriptionLabel.attributedStringValue)
        }
        
        items.append(self.imageView.image!)
        
        if let url = self.userActivity?.webpageURL {
            
            items.append(url)
        }
        
        let sharingServicePicker = NSSharingServicePicker(items: items)
        
        sharingServicePicker.delegate = self
        
        sharingServicePicker.showRelativeToRect(sender.bounds, ofView: sender, preferredEdge: NSRectEdge.MinY)
    }
    
    // MARK: - Private Methods
    
    /// Fetches the data from cache.
    private func loadData() {
        
        self.userActivity = nil
        
        switch profile {
            
        case .currentUser:
            
            if let currentMember = Store.shared.authenticatedMember {
                
                if let speakerRole = currentMember.speakerRole {
                    
                    let person = Speaker(managedObject: speakerRole)
                    
                    configureView(person)
                    
                } else {
                    
                    let member = Member(managedObject: currentMember)
                    
                    configureView(member)
                }
                
            } else {
                
                //fatalError("Cannot show current user, not logged in")
            }
            
        case let .speaker(identifier):
            
            // load speaker from cache
            if let speakerManagedObject = try! SpeakerManagedObject.find(identifier, context: Store.shared.managedObjectContext) {
                
                let speaker = Speaker(managedObject: speakerManagedObject)
                
                let summit = Summit(managedObject: self.currentSummit!)
                
                configureView(speaker)
                
                // set user activity for handoff
                let userActivity = NSUserActivity(activityType: AppActivity.view.rawValue)
                 userActivity.requiredUserInfoKeys = [AppActivityUserInfo.type.rawValue, AppActivityUserInfo.identifier.rawValue]
                userActivity.title = self.title
                userActivity.webpageURL = NSURL(string: speaker.toWebpageURL(summit))
                userActivity.userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.speaker.rawValue, AppActivityUserInfo.identifier.rawValue: identifier]
                
                userActivity.becomeCurrent()
                
                self.userActivity = userActivity
            }
            
        case let .member(identifier):
            
            if let member = try! Member.find(identifier, context: Store.shared.managedObjectContext) {
                
                configureView(member)
            }
        }
    }
    
    private func configureView<T: Person>(person: T) {
        
        let _ = self.view
        
        assert(viewLoaded)
        
        self.nameLabel.stringValue = person.name
        self.titleLabel.stringValue = person.title ?? ""
        
        self.imageView.image = NSImage(named: "generic-user-avatar")
        
        if let imageURL = NSURL(string: person.pictureURL) {
            
            self.imageView.loadCached(imageURL)
        }
        
        // set description
        if let htmlString = person.biography,
            let data = htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false),
            let attributedString = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            where attributedString.string.isEmpty == false {
            
            self.descriptionView.hidden = false
            
            let range = NSMakeRange(0, attributedString.length)
            
            attributedString.addAttribute(NSFontAttributeName, value: NSFont.systemFontOfSize(14), range: range)
            
            self.descriptionLabel.attributedStringValue = attributedString
            
        } else {
            
            self.descriptionView.hidden = true
            self.descriptionLabel.stringValue = ""
        }
        
        locationView.hidden = true
        
        twitterView.hidden = person.twitter == nil
        twitterLabel.stringValue = person.twitter ?? ""
        
        ircView.hidden = person.irc == nil
        ircLabel.stringValue = person.irc ?? ""
    }
    
    // MARK: - NSSharingServicePickerDelegate
    
    func sharingServicePicker(sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [AnyObject], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
        
        var customItems = [NSSharingService]()
        
        if let airdrop = NSSharingService(named: NSSharingServiceNameSendViaAirDrop) {
            
            customItems.append(airdrop)
        }
        
        if let safariReadList = NSSharingService(named: NSSharingServiceNameAddToSafariReadingList) {
            
            customItems.append(safariReadList)
        }
        
        if let url = self.userActivity?.webpageURL?.absoluteString {
            
            let copyLink = NSSharingService(copyLink: url)
            
            customItems.append(copyLink)
        }
        
        return customItems + proposedServices
    }
    
    func sharingServicePicker(sharingServicePicker: NSSharingServicePicker, delegateForSharingService sharingService: NSSharingService) -> NSSharingServiceDelegate? {
        
        return self
    }
    
    // MARK: - NSSharingServiceDelegate
    
    func sharingService(sharingService: NSSharingService, willShareItems items: [AnyObject]) {
        
        sharingService.subject = nameLabel.stringValue
    }
}

// MARK: - Supporting Types

/// Data type used the configure the member profile-related View Controllers.
public enum PersonIdentifier {
    
    case currentUser
    case speaker(Identifier)
    case member(Identifier)
    
    public init() {
        
        self = .currentUser
    }
    
    public init(speaker: Speaker) {
        
        self = .speaker(speaker.identifier)
    }
    
    public init(member: Member) {
        
        self = .member(member.identifier)
    }
}
