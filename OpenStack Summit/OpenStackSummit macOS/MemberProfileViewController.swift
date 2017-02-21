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

final class MemberProfileViewController: NSViewController, NSSharingServicePickerDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var titleLabel: NSTextField!
    
    @IBOutlet private(set) weak var biographyTextView: NSTextView!
    
    @IBOutlet private(set) weak var imageView: NSImageView!
    
    @IBOutlet private(set) weak var locationView: NSBox!
    
    @IBOutlet private(set) weak var locationLabel: NSTextField!
    
    @IBOutlet private(set) weak var twitterView: NSBox!
    
    @IBOutlet private(set) weak var twitterLabel: NSTextField!
    
    @IBOutlet private(set) weak var ircView: NSBox!
    
    @IBOutlet private(set) weak var ircLabel: NSTextField!
    
    // MARK: - Properties
    
    var profile: MemberProfileIdentifier = .currentUser {
        
        didSet { loadData() }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    // MARK: - Actions
    
    @IBAction func share(sender: NSButton) {
        
        var items = [AnyObject]()
        
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
        
        self.nameLabel.stringValue = person.name
        self.titleLabel.stringValue = person.title ?? ""
        
        self.imageView.image = NSImage(named: "generic-user-avatar")
        
        if let imageURL = NSURL(string: person.pictureURL) {
            
            self.imageView.loadCached(imageURL)
        }
        
        self.biographyTextView.string = ""
        
        if let biography = person.biography,
            let data = biography.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false),
            let attributedString = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
            
            let range = NSMakeRange(0, attributedString.length)
            
            attributedString.addAttribute(NSFontAttributeName, value: NSFont.systemFontOfSize(14), range: range)
            
            self.biographyTextView.textStorage!.appendAttributedString(attributedString)
            
        }
        
        locationView.hidden = true
        
        twitterView.hidden = person.twitter == nil
        twitterLabel.stringValue = person.twitter ?? ""
        
        ircView.hidden = person.irc == nil
        ircLabel.stringValue = person.irc ?? ""
    }
}
