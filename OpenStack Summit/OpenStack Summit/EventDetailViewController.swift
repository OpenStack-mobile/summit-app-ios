	//
//  EventDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Haneke
import Cosmos
import AHKActionSheet
import SwiftSpinner
import CoreSummit

final class EventDetailViewController: UIViewController, RevealViewController, ShowActivityIndicatorProtocol, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var feedbackListActivityIndicator: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var eventDetailTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var speakersTableView: UITableView!
    @IBOutlet weak var feedbackTableView: UITableView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var sponsorsLabel: UILabel!
    @IBOutlet weak var summitTypesLabel: UILabel!
    @IBOutlet weak var summitTypesView: UIView!
    @IBOutlet weak var summitTypesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sponsorsLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scheduledButton: UIBarButtonItem!
    @IBOutlet weak var speakersHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var averageFeedbackView: UIView!
    @IBOutlet weak var averageFeedbackRatingView: CosmosView!
    @IBOutlet weak var feedbackButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var averageFeedbackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var feedbackTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var submenuButton: UIBarButtonItem!
    @IBOutlet weak var tagsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var tagsView: UIView!
    @IBOutlet weak var eventDetailLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var levelLabelHeightConstraint: NSLayoutConstraint!    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var trackLabelHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var event: Identifier!
    
    // MARK: - Private Properties
    
    private var eventDetail: EventDetail!
    private var eventDescriptionHTML = ""
    private var myFeedbackForEvent: Feedback?
    private var feedbackPage = 1
    private var feedbackObjectsPerPage = 5
    private var feedbackList = [FeedbackDetail]()
    private var loadedAllFeedback = false
    private var loadingFeedback = false
    
    private let borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    private let borderWidth = 1
    private var actionSheet: AHKActionSheet!
    
    // MARK: - Accessors
    
    private(set) var eventTitle: String! {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    private(set) var eventDescription: String = "" {
        
        didSet {
            eventDescriptionHTML = String(format:"<span style=\"font-family: Arial; font-size: 13\">%@</span>", eventDescription)
            let attrStr = try! NSAttributedString(data: eventDescriptionHTML.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            eventDetailTextView.attributedText = attrStr
            eventDetailTextView.sizeToFit()
        }
    }
    private(set) var date: String! {
        get {
            return timeLabel.text
        }
        set {
            timeLabel.text = newValue
        }
    }
    
    private(set) var location: String! {
        get {
            return locationLabel.text
        }
        set {
            locationLabel.text = newValue
            if (newValue == nil || newValue.isEmpty) {
                locationViewHeightConstraint.constant = 0
            }
            else {
                locationViewHeightConstraint.constant = 60
            }
        }
    }

    private(set) var sponsors: String! {
        get {
            return sponsorsLabel.text
        }
        set {
            if (newValue == nil || newValue.isEmpty) {
                sponsorsLabelHeightConstraint.constant = 0
            }
            else {
                sponsorsLabelHeightConstraint.constant = 60
            }
            sponsorsLabel.updateConstraints()
            sponsorsLabel.text = newValue
        }
    }
    
    private(set) var summitTypes: String! {
        get {
            return summitTypesLabel.text
        }
        set {
            summitTypesLabel.text = newValue
        }
    }
    
    private(set) var tags: String! {
        get {
            return tagsLabel.text
        }
        set {
            tagsLabel.text = newValue
            tagsViewHeightConstraint.constant = newValue == nil || newValue.isEmpty ? 0 : 60
            tagsView.updateConstraints()
        }
    }
    
    private(set) var allowFeedback: Bool {
        get {
            return feedbackButtonHeightConstraint.constant > 0
        }
        set {
            feedbackButtonHeightConstraint.constant = newValue ? 30 : 0
            feedbackTableHeightConstraint.constant =  newValue ? 30 : 0
            feedbackButton.updateConstraints()
            feedbackTableView.updateConstraints()
            navigationItem.rightBarButtonItems![0].image = newValue ? UIImage(named:"Submenu_Feedback") : nil
            navigationItem.rightBarButtonItems![0].enabled = newValue
        }
    }
    
    private(set) var hasSpeakers: Bool {
        get {
            return speakersHeightConstraint.constant > 0
        }
        set {
            speakersHeightConstraint.constant = newValue ? CGFloat(eventDetail.speakers.count * 79) : 0
            speakersTableView.updateConstraints()
        }
    }
    
    private(set) var hasAnyFeedback: Bool  {
        get {
            return feedbackTableHeightConstraint.constant > 0
        }
        set {
            feedbackTableHeightConstraint.constant = newValue ? 200 : 0
            feedbackTableView.updateConstraints()
        }
    }
    
    private(set) var scheduled: Bool = false {
        
        didSet {
            
            if (scheduled) {
                scheduledButton.image = UIImage(named:"checked_active")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            }
            else {
                scheduledButton.image = UIImage(named:"unchecked")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            }
        }
    }
    
    private(set) var averageFeedback: Double {
        get {
            return averageFeedbackRatingView.rating
        }
        set {
            averageFeedbackRatingView.rating = newValue
        }
    }
    
    private(set) var hasAverageFeedback: Bool {
        get {
            return feedbackButtonHeightConstraint.constant > 0
        }
        
        set {
            if newValue {
                if averageFeedbackViewHeightConstraint != nil {
                    averageFeedbackView.removeConstraint(averageFeedbackViewHeightConstraint)
                    averageFeedbackViewHeightConstraint = nil                    
                }
            }
            else {
                if averageFeedbackViewHeightConstraint == nil {
                    averageFeedbackViewHeightConstraint = NSLayoutConstraint(item: averageFeedbackView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0)
                    averageFeedbackView.addConstraint(averageFeedbackViewHeightConstraint)
                }
            }
            averageFeedbackView.updateConstraints()
        }
    }
    
    private(set) var isScheduledStatusVisible: Bool {
        get {
            
            return navigationItem.rightBarButtonItems![0].enabled
        }
        set {
            
            if (!newValue) {
                navigationItem.rightBarButtonItems![1].image = nil
            }
            navigationItem.rightBarButtonItems![1].enabled = newValue
        }
    }
    
    private(set) var level: String! {
        get {
            return levelLabel.text
        }
        set {
            levelLabel.text = newValue
            levelLabelHeightConstraint.constant = newValue == nil || newValue.isEmpty ? 0 : 60
            levelLabel.updateConstraints()
        }
    }
    
    private(set) var track: String! {
        get {
            return trackLabel.text
        }
        set {
            if (newValue == nil || newValue.isEmpty) {
                trackLabelHeightConstraint.constant = 0
            }
            else {
                trackLabelHeightConstraint.constant = 30
            }
            trackLabel.updateConstraints()
            trackLabel.text = newValue
        }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMenuButton()
        
        scheduledButton.target = self
        scheduledButton.action = #selector(EventDetailViewController.toggleSchedule(_:))
        submenuButton.target = self
        submenuButton.action = #selector(EventDetailViewController.leaveFeedback)
        
        feedbackButton.layer.cornerRadius = 10

        timeView.addBottomBorderWithColor(borderColor, width: CGFloat(borderWidth))
        locationView.addBottomBorderWithColor(borderColor, width: CGFloat(borderWidth))
        summitTypesView.addTopBorderWithColor(borderColor, width: CGFloat(borderWidth))
        summitTypesView.addBottomBorderWithColor(borderColor, width: CGFloat(borderWidth))
        feedbackTableView.addTopBorderWithColor(borderColor, width: CGFloat(borderWidth))
        tagsView.addBottomBorderWithColor(borderColor, width: CGFloat(borderWidth))
        
        actionSheet = AHKActionSheet()
        actionSheet.addButtonWithTitle("Feedback", image: nil, type: .Default) { actsheet in
            self.leaveFeedback()
        }
        actionSheet.addButtonWithTitle("Share", image: nil, type: .Default, handler: nil)
        actionSheet.blurTintColor = UIColor(white: 0.0, alpha: 0.75)
        actionSheet.separatorColor = UIColor(white: 1.0, alpha: 0.3)
        actionSheet.blurRadius = 8.0;
        actionSheet.buttonHeight = 50.0;
        actionSheet.buttonTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
        actionSheet.cancelButtonTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
        
        // setup table views
        feedbackTableView.registerNib(R.nib.feedbackTableViewCell)
        feedbackTableView.delegate = self
        feedbackTableView.dataSource = self
        
        //speakersTableView.registerNib(R.nib.peopleTableViewCell)
        speakersTableView.delegate = self
        speakersTableView.dataSource = self
        
        navigationItem.title = "EVENTS"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    // MARK: - Actions
    
    @IBAction func showLocation(sender: UITapGestureRecognizer) {
        
        guard let venue = eventDetail.venue
            else { return }
        
        showLocationDetail(venue)
    }
    
    /// Leave feedback button
    @IBAction func leaveFeedback(sender: AnyObject? = nil) {
        
        let feedbackVC = R.storyboard.feedback.feedbackEditViewController()!
        
        feedbackVC.event = event
        
        self.showViewController(feedbackVC, sender: self)
    }
    
    @IBAction func loadMoreFeedback(sender: AnyObject) {
        
        loadFeedback()
    }
    
    @IBAction func toggleSchedule(sender: UIBarButtonItem) {
        
        //presenter.toggleScheduledStatus()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        guard let realmEvent = RealmSummitEvent.find(self.event, realm: Store.shared.realm)
            else { fatalError("Not in cache") }
        
        eventDetail = EventDetail(realmEntity: realmEvent)
        
        loadedAllFeedback = false
        loadingFeedback = false
        feedbackPage = 1
        feedbackList.removeAll()
        
        // get feedback for current user
        if let member = Store.shared.authenticatedMember,
            let realmFeedback = member.feedback(forEvent: event) {
            
            myFeedbackForEvent = Feedback(realmEntity: realmFeedback)
        }
        
        self.eventTitle = eventDetail.name
        self.eventDescription = eventDetail.eventDescription
        self.location = eventDetail.location
        self.date = eventDetail.dateTime
        self.sponsors = eventDetail.sponsors
        self.summitTypes = eventDetail.summitTypes
        self.allowFeedback = eventDetail.allowFeedback && eventDetail.finished /* && interactor.isLoggedInAndConfirmedAttendee() */ && myFeedbackForEvent == nil
        self.hasSpeakers = eventDetail.speakers.count > 0
        self.hasAnyFeedback = false
        self.speakersTableView.reloadData()
        self.scheduled = Store.shared.isEventScheduledByLoggedMember(event: event)
        self.isScheduledStatusVisible = /* Store.shared.isLoggedInAndConfirmedAttendee() */ false
        self.tags = eventDetail.tags
        self.level = eventDetail.level
        self.track = eventDetail.track
        self.hasAverageFeedback = false
        
        if eventDetail.allowFeedback && eventDetail.finished {
            loadAverageFeedback()
            loadFeedback()
        }
    }
    
    private func loadFeedback() {
        
        if (loadingFeedback || loadedAllFeedback) {
            return
        }
        
        loadingFeedback = true
        feedbackListActivityIndicator.hidden = false
        
        Store.shared.feedback(event: event, page: feedbackPage, objectsPerPage: feedbackObjectsPerPage) { [weak self] (response) in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                guard let controller = self else { return }
                
                defer {
                    controller.loadingFeedback = false
                    controller.feedbackListActivityIndicator.hidden = true
                }
                
                switch response {
                    
                case .Error: break // ignore?
                    
                case let .Value(feedbackPage):
                    
                    var filteredFeedback = [Identifier]()
                    
                    if let myFeedback = Store.shared.authenticatedMember?.feedback(forEvent: controller.event) {
                        
                        for feedback in feedbackPage {
                            if feedback.owner != myFeedback.owner {
                                filteredFeedback.append(feedback.identifier)
                            }
                        }
                        if !controller.feedbackList.contains({ $0.identifier ==  myFeedback.id }) {
                            filteredFeedback.insert(myFeedback.id, atIndex: 0)
                        }
                    }
                    else {
                        filteredFeedback = feedbackPage.map { $0.identifier }
                    }
                    
                    let realmFeedback = filteredFeedback.map { RealmFeedback.find($0, realm: Store.shared.realm)! }
                    let feedbackDetail = FeedbackDetail.from(realm: realmFeedback)
                    
                    controller.feedbackList.appendContentsOf(feedbackDetail)
                    controller.feedbackTableView.reloadData()
                    controller.hasAnyFeedback = controller.feedbackList.count > 0
                    controller.feedbackPage += 1
                    controller.loadedAllFeedback = feedbackPage.count < controller.feedbackObjectsPerPage
                }
            }
        }
    }
    
    private func loadAverageFeedback() {
        
        Store.shared.averageFeedback(event: event) { [weak self] (response) in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                guard let controller = self else { return }
                
                switch response {
                    
                case .Error: break
                    
                case let .Value(averageFeedback):
                    
                    controller.hasAverageFeedback = averageFeedback != 0
                    controller.averageFeedback = averageFeedback
                }
            }
        }
    }
    
    private func configure(cell cell: PeopleTableViewCell, at indexPath: NSIndexPath) {
        
        let speaker = eventDetail.speakers[indexPath.row]
        cell.name = speaker.name
        cell.title = speaker.title
        cell.pictureURL = speaker.pictureURL
        cell.isModerator = eventDetail.moderator != nil && speaker.identifier == eventDetail.moderator?.identifier
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
    }
    
    private func configure(cell cell: FeedbackTableViewCell, at indexPath: NSIndexPath) {
        
        let feedback = feedbackList[indexPath.row]
        
        cell.eventName = ""
        cell.owner = feedback.owner
        cell.rate = Double(feedback.rate)
        cell.review = feedback.review
        cell.date = feedback.date
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == speakersTableView) {
            
            return eventDetail.speakers.count
            
        } else {
            
            return feedbackList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == speakersTableView {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.speakerTableViewCell, forIndexPath: indexPath)!
            configure(cell: cell, at: indexPath)
            return cell
        }
        else if tableView == feedbackTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.feedbackTableViewCell, forIndexPath: indexPath)!
            configure(cell: cell, at: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let speaker = eventDetail.speakers[indexPath.row]
        
        let memberVC = R.storyboard.memberProfile.memberProfileDetailViewController()!
        
        memberVC.profile = MemberProfileIdentifier(speaker: speaker)
        
        self.showViewController(memberVC, sender: self)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == feedbackTableView {
            return UITableViewAutomaticDimension
        }
        else {
            return tableView.rowHeight
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == feedbackTableView {
            return UITableViewAutomaticDimension
        }
        else {
            return tableView.rowHeight
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            
            loadFeedback()
        }
    }
}
