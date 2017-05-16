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
        
        didSet { if isViewLoaded { configureView() } }
    }
    
    var contextMenu: ContextMenu {
        
        var items = [Any]()
        
        if let url = self.userActivity?.webpageURL {
            
            items.append(url)
        }
        
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
        
        return ContextMenu(actions: [], shareItems: items, systemActions: true)
    }
    
    // MARK: - Private Properties
    
    private var loadingTableView = false
    
    private var data = [Data]()
    
    private var showNonConfirmedWarning = false
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup navigation bar
        addContextMenuBarButtonItem()
        
        // setup table view
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        // setup toolbar
        setupToolbar()
        
        // configure UI
        OperationQueue.main.addOperation { [weak self] in self?.configureView() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // handoff
        self.userActivity?.becomeCurrent()
        
        // toolbar
        self.navigationController?.setToolbarHidden(!showNonConfirmedWarning, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // setup after animation finished to prevent lag
        configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // handoff
        self.userActivity?.resignCurrent()
        
        // toolbar
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func updateUserActivityState(_ userActivity: NSUserActivity) {
        
        switch profile {
            
        case let .speaker(identifier):
            
            let userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.speaker.rawValue,
                            AppActivityUserInfo.identifier.rawValue: identifier] as [String : Any]
            
            userActivity.addUserInfoEntries(from: userInfo as [AnyHashable: Any])
            
        default: break
        }
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Actions
    
    @IBAction func nonConfirmedWarningTapped(_ sender: AnyObject? = nil) {
        
        self.performSegue(withIdentifier: R.segue.personDetailViewController.showAttendeeConfirm, sender: self)
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(_ sender: AnyObject? = nil) {
        
        configureView()
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
        headerView.titleLabel.isHidden = (person.title ?? "").isEmpty
        headerView.imageView.hnk_setImageFromURL(person.picture.environmentScheme, placeholder: #imageLiteral(resourceName: "generic-user-avatar"))
        
        // configure cells
        
        loadingTableView = true
        
        data = []
        
        switch profile {
            
        case .currentUser:
            
            let isConfirmed = Store.shared.isLoggedInAndConfirmedAttendee
            
            data.append(.attendeeTicket(confirmed: isConfirmed))
            
            showNonConfirmedWarning = Preference.goingToSummit && isConfirmed == false
            
        default:
            
            showNonConfirmedWarning = false
        }
        
        let links = Links(twitter: person.twitter ?? "", irc: person.irc ?? "", linkedIn: person.linkedIn ?? "")
        
        if links.isEmpty == false {
            
            data.append(.links(links))
        }
        
        if let biography = person.biography,
            let data = biography.data(using: String.Encoding.unicode, allowLossyConversion: false),
            let attributedString = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
            
            let range = NSMakeRange(0, attributedString.length)
            
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14), range: range)
            
            self.data.append(.biography(attributedString))
        }
        
        loadingTableView = false
        
        tableView.reloadData()
        
        // set user activity for handoff
        
        if let speaker = person as? Speaker,
            let summitManagedObject = self.currentSummit {
            
            let summit = Summit(managedObject: summitManagedObject)
            
            let userActivity = NSUserActivity(activityType: AppActivity.view.rawValue)
            userActivity.title = speaker.name
            userActivity.webpageURL = speaker.webpage(for: summit)
            
            userActivity.userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.speaker.rawValue, AppActivityUserInfo.identifier.rawValue: speaker.identifier]
            userActivity.requiredUserInfoKeys = [AppActivityUserInfo.type.rawValue, AppActivityUserInfo.identifier.rawValue]
            
            self.userActivity = userActivity
            
            userActivity.becomeCurrent()
            
        } else {
            
            self.userActivity = nil
        }
    }
    
    private func setupToolbar() {
        
        navigationController?.toolbar.barTintColor = UIColor(hexString: "#FAD438")!
        navigationController?.toolbar.isTranslucent = false
        
        let action = #selector(nonConfirmedWarningTapped)
        
        let imageBarButtonItem = UIBarButtonItem()
        imageBarButtonItem.target = self
        imageBarButtonItem.action = action
        imageBarButtonItem.image = #imageLiteral(resourceName: "messageWarning")
        imageBarButtonItem.tintColor = UIColor(hexString: "#4A4A4A")
        
        let textBarButtonItem = UIBarButtonItem()
        textBarButtonItem.title = "Don't forget to add your EventBrite Order #"
        textBarButtonItem.style = .plain
        textBarButtonItem.target = self
        textBarButtonItem.action = action
        textBarButtonItem.tintColor = UIColor(hexString: "#4A4A4A")
        textBarButtonItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "OpenSans", size: 13)!], for: UIControlState())
        
        toolbarItems = [imageBarButtonItem, textBarButtonItem]
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Profile")
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // WebKit or UIKit is causing the tableview cell to refresh without reloading.
        // http://stackoverflow.com/questions/23926541/how-can-initializing-nsattributedstring-in-tableviewheightforrowatindexpath-be
        guard loadingTableView == false else {
            
            return UITableViewCell()
        }
        
        let data = self.data[indexPath.row]
        
        switch data {
            
        case let .attendeeTicket(confirmed):
            
            if confirmed {
                
                return tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.personDetailConfirmedAttendeeCell)!
                
            } else {
                
                return tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.personDetailNonConfirmedAttendeeCell)!
            }
            
        case let .links(links):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.personDetailLinksCell)!
            
            cell.twitterView.isHidden = links.twitter.isEmpty
            cell.twitterView.label.text = links.twitter
            
            cell.ircView.isHidden = links.irc.isEmpty
            cell.ircView.label.text = links.irc
            
            cell.linkedInView.isHidden = links.linkedIn.isEmpty
            cell.linkedInView.label.text = links.linkedIn
            
            return cell
            
        case let .biography(text):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.personDetailDescriptionCell)!
            
            cell.textView.attributedText = text
            cell.textView.textContainerInset = UIEdgeInsets.zero
            cell.textView.sizeToFit()
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        
        return 128
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return UITableViewAutomaticDimension
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var inset = self.separatorInset
        inset.right = self.bounds.size.width - inset.left
        self.separatorInset = inset
    }
}
