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

final class PersonDetailViewController: UITableViewController, IndicatorInfoProvider, ContextMenuViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) var headerView: PersonDetailHeaderView!
    
    // MARK: - Properties
    
    var profile: PersonIdentifier = .currentUser {
        
        didSet { configureView() }
    }
    
    var contextMenu: ContextMenu {
        
        var items = [AnyObject]()
        
        items.append(self.headerView.nameLabel.text ?? "")
        
        for data in self.data {
            
            switch data {
                
            case let .biography(biography):
                
                items.append(biography)
                
            case let .links(links):
                
                items += [links.twitter, links.irc, links.linkedIn]
                
            case .attendeeTicket: break
            }
        }
        
        items.append(self.headerView.imageView.image!)
        
        if let url = self.userActivity?.webpageURL {
            
            items.append(url)
        }
        
        return ContextMenu(actions: [], shareItems: items, systemActions: true)
    }
    
    // MARK: - Private Properties
    
    private var data = [Data]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup navigation bar
        addContextMenuBarButtonItem()
        
        // setup table view
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // handoff
        self.userActivity?.becomeCurrent()
        
        configureView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // handoff
        self.userActivity?.resignCurrent()
    }
    
    override func updateUserActivityState(userActivity: NSUserActivity) {
        
        switch profile {
            
        case let .speaker(identifier):
            
            let userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.speaker.rawValue,
                            AppActivityUserInfo.identifier.rawValue: identifier]
            
            userActivity.addUserInfoEntriesFromDictionary(userInfo as [NSObject : AnyObject])
            
        default: break
        }
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        // fetch profile
        
        switch profile {
            
        case .currentUser:
            
            if let currentMember = Store.shared.authenticatedMember {
                
                if let speakerRole = currentMember.speakerRole {
                    
                    let speaker = Speaker(managedObject: speakerRole)
                    
                    configureView(with: speaker)
                    
                } else {
                    
                    let member = Member(managedObject: currentMember)
                    
                    configureView(with: member)
                }
                
            } else {
                
                fatalError("Cannot show current user, not logged in")
            }
            
        case let .speaker(identifier):
            
            guard let speaker = try! Speaker.find(identifier, context: Store.shared.managedObjectContext)
               else { fatalError("Invalid identfier: \(profile)") }
            
            configureView(with: speaker)
            
        case let .member(identifier):
            
            guard let member = try! Member.find(identifier, context: Store.shared.managedObjectContext)
                else { fatalError("Invalid identfier: \(profile)") }
            
            configureView(with: member)
        }
    }
    
    private func configureView<T: Person>(with person: T) {
        
        // configure header
        
        headerView.nameLabel.text = person.name
        headerView.titleLabel.text = person.title ?? ""
        headerView.titleLabel.hidden = (person.title ?? "").isEmpty
        headerView.imageView.image = R.image.genericUserAvatar()!
        
        if let imageURL = NSURL(string: person.pictureURL) {
            
            headerView.imageView.hnk_setImageFromURL(imageURL)
        }
        
        // configure cells
        
        data = []
        
        switch profile {
        case .currentUser:
            
            let isConfirmed = Store.shared.isLoggedInAndConfirmedAttendee
            
            data.append(.attendeeTicket(confirmed: isConfirmed))
            
        default: break
        }
        
        let links = Links(twitter: person.twitter ?? "", irc: person.irc ?? "", linkedIn: person.linkedIn ?? "")
        
        if links.isEmpty == false {
            
            data.append(.links(links))
        }
        
        if let biography = person.biography,
            let data = biography.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false),
            let attributedString = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
            
            let range = NSMakeRange(0, attributedString.length)
            
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: range)
            
            self.data.append(.biography(attributedString))
        }
        
        tableView.reloadData()
        
        // set user activity for handoff
        
        let personURL: NSURL?
        
        if let speaker = person as? Speaker,
            let summitManagedObject = self.currentSummit {
            
            let summit = Summit(managedObject: summitManagedObject)
            
            let userActivity = NSUserActivity(activityType: AppActivity.view.rawValue)
            userActivity.title = speaker.name
            personURL = NSURL(string: speaker.toWebpageURL(summit))
            userActivity.webpageURL = personURL
            
            userActivity.userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.speaker.rawValue, AppActivityUserInfo.identifier.rawValue: speaker.identifier]
            userActivity.requiredUserInfoKeys = [AppActivityUserInfo.type.rawValue, AppActivityUserInfo.identifier.rawValue]
            
            self.userActivity = userActivity
            
            userActivity.becomeCurrent()
            
        } else {
            
            self.userActivity = nil
        }
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Profile")
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let data = self.data[indexPath.row]
        
        switch data {
            
        case let .attendeeTicket(confirmed):
            
            if confirmed {
                
                return tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.personDetailConfirmedAttendeeCell)!
                
            } else {
                
                return tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.personDetailNonConfirmedAttendeeCell)!
            }
            
        case let .links(links):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.personDetailLinksCell)!
            
            cell.twitterView.hidden = links.twitter.isEmpty
            cell.twitterView.label.text = links.twitter
            
            cell.ircView.hidden = links.irc.isEmpty
            cell.ircView.label.text = links.irc
            
            cell.linkedInView.hidden = links.linkedIn.isEmpty
            cell.linkedInView.label.text = links.linkedIn
            
            return cell
            
        case let .biography(text):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.personDetailDescriptionCell)!
            
            cell.textView.attributedText = text
            cell.textView.textContainerInset = UIEdgeInsetsZero
            cell.textView.sizeToFit()
            
            return cell
        }
    }
}

// MARK: - Supporting Types

private extension PersonDetailViewController {
    
    enum Data {
        
        case attendeeTicket(confirmed: Bool)
        case links(Links)
        case biography(NSAttributedString)
    }
    
    struct Links {
        
        var twitter: String
        var irc: String
        var linkedIn: String
        
        var isEmpty: Bool {
            
            return twitter.isEmpty
                && irc.isEmpty
                && linkedIn.isEmpty
        }
    }
}

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

final class PersonDetailHeaderView: UIView {
    
    @IBOutlet private(set) weak var imageView: UIImageView!
    
    @IBOutlet private(set) weak var nameLabel: CopyableLabel!
    
    @IBOutlet private(set) weak var titleLabel: CopyableLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
    }
}

final class PersonDetailLinksTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var twitterView: PersonDetailLinkView!
    
    @IBOutlet private(set) weak var ircView: PersonDetailLinkView!
    
    @IBOutlet private(set) weak var linkedInView: PersonDetailLinkView!
}

final class PersonDetailLinkView: UIStackView {
    
    @IBOutlet private(set) weak var label: CopyableLabel!
}

final class PersonDetailDescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var textView: UITextView!
}

// MARK: - Legacy

final class OldMemberProfileDetailViewController: UIViewController, IndicatorInfoProvider, ContextMenuViewController {
    
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
    
    var profile: PersonIdentifier = .currentUser
    
    var contextMenu: ContextMenu {
        
        var items = [AnyObject]()
        
        items.append(self.name)
        
        if let biographyText = self.bioTextView.attributedText {
            
            items.append(biographyText)
        }
        
        items.append(self.pictureImageView.image!)
        
        if let url = self.userActivity?.webpageURL {
            
            items.append(url)
        }
                
        return ContextMenu(actions: [], shareItems: items, systemActions: true)
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addContextMenuBarButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // fetch from cache
        loadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
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
    
    // MARK: - Methods
    
    /// Fetches the data from cache. 
    private func loadData() {
        
        self.userActivity = nil
        
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
                
                let summit = Summit(managedObject: self.currentSummit!)
                
                updateUI(.Value(speaker))
                
                // set user activity for handoff
                let userActivity = NSUserActivity(activityType: AppActivity.view.rawValue)
                userActivity.title = self.title
                userActivity.webpageURL = NSURL(string: speaker.toWebpageURL(summit))
                
                userActivity.userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.speaker.rawValue, AppActivityUserInfo.identifier.rawValue: identifier]
                userActivity.requiredUserInfoKeys = [AppActivityUserInfo.type.rawValue, AppActivityUserInfo.identifier.rawValue]
                
                userActivity.becomeCurrent()
                
                self.userActivity = userActivity
                
            } else {
                
                updateUI(ErrorValue<Speaker>.Error(Error.getSpeakerProfile))
            }
            
        case let .member(identifier):
            
            if let member = try! Member.find(identifier, context: Store.shared.managedObjectContext) {
                
                updateUI(.Value(member))
                
            } else {
                
                updateUI(ErrorValue<Member>.Error(Error.getMemberProfile))
            }
        }
    }
    
    private func updateUI<T: Person>(value: ErrorValue<T>) {
        
        switch value {
            
        case let .Error(error):
            
            showErrorAlert((error as! NSError).localizedDescription)
            
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
