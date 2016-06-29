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

final class EventDetailViewController: UIViewController, RevealViewController, ShowActivityIndicatorProtocol /*, UITableViewDelegate, UITableViewDataSource */ {
    
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
    
    /*
    // MARK: - Private Properties
    
    private var eventDescriptionHTML = ""
    private var speakerCellIdentifier = "speakerTableViewCell"
    private var feedbackCellIdentifier = "feedbackTableViewCell"
    private let borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    private let borderWidth = 1
    private var scheduledInternal = false
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
    private(set) var eventDescription: String! {
        get {
            return eventDescriptionHTML
        }
        set {
            eventDescriptionHTML = String(format:"<span style=\"font-family: Arial; font-size: 13\">%@</span>",newValue)
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
            speakersHeightConstraint.constant = newValue ? CGFloat(presenter.getSpeakersCount() * 79) : 0
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
    
    private(set) var scheduled: Bool  {
        get {
            return scheduledInternal
        }
        set {
            scheduledInternal = newValue
            if (scheduledInternal) {
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
        scheduledButton.action = Selector("toggleSchedule:")
        submenuButton.target = self
        submenuButton.action = Selector("leaveFeedback:")
        
        feedbackButton.layer.cornerRadius = 10

        timeView.addBottomBorderWithColor(borderColor, width: CGFloat(borderWidth))
        locationView.addBottomBorderWithColor(borderColor, width: CGFloat(borderWidth))
        summitTypesView.addTopBorderWithColor(borderColor, width: CGFloat(borderWidth))
        summitTypesView.addBottomBorderWithColor(borderColor, width: CGFloat(borderWidth))
        feedbackTableView.addTopBorderWithColor(borderColor, width: CGFloat(borderWidth))
        tagsView.addBottomBorderWithColor(borderColor, width: CGFloat(borderWidth))
        
        actionSheet = AHKActionSheet()
        actionSheet.addButtonWithTitle("Feedback", image: nil, type: .Default) { actsheet in
            self.presenter.leaveFeedback()
        }
        actionSheet.addButtonWithTitle("Share", image: nil, type: .Default, handler: nil)
        actionSheet.blurTintColor = UIColor(white: 0.0, alpha: 0.75)
        actionSheet.separatorColor = UIColor(white: 1.0, alpha: 0.3)
        actionSheet.blurRadius = 8.0;
        actionSheet.buttonHeight = 50.0;
        actionSheet.buttonTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
        actionSheet.cancelButtonTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
        
        feedbackTableView.registerNib(UINib(nibName: "FeedbackTableViewCell", bundle: nil), forCellReuseIdentifier: feedbackCellIdentifier)
        
        navigationItem.title = "EVENTS"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    // MARK: - Actions
        
    @IBAction func leaveFeedback(sender: AnyObject) {
        
    }
    
    @IBAction func showLocation(sender: UITapGestureRecognizer) {
        
    }
    
    @IBAction func loadMoreFeedback(sender: AnyObject) {
        
    }
    
    @IBAction func toggleSchedule(sender: UIBarButtonItem) {
        
        
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        loadedAllFeedback = false
        loadingFeedback = false
        feedbackPage = 1
        feedbackList.removeAll()
        event = interactor.getEventDetail(eventId)
        myFeedbackForEvent = interactor.getMyFeedbackForEvent(eventId)
        
        self.eventTitle = event.name
        self.eventDescription = event.eventDescription
        self.location = event.location
        self.date = event.dateTime
        self.sponsors = event.sponsors
        self.summitTypes = event.summitTypes
        self.allowFeedback = event.allowFeedback && event.finished && interactor.isLoggedInAndConfirmedAttendee() && myFeedbackForEvent == nil
        self.hasSpeakers = event.speakers.count > 0
        self.hasAnyFeedback = false
        self.reloadSpeakersData()
        self.scheduled = interactor.isEventScheduledByLoggedMember(eventId)
        self.isScheduledStatusVisible = interactor.isLoggedInAndConfirmedAttendee()
        self.tags = event.tags
        self.level = event.level
        self.track = event.track
        self.hasAverageFeedback = false
        
        if event.allowFeedback && event.finished {
            loadAverageFeedback()
            loadFeedback()
        }
    }
    
    func reloadSpeakersData() {
        speakersTableView.delegate = self
        speakersTableView.dataSource = self
        speakersTableView.reloadData()
    }
    
    func reloadFeedbackData() {
        feedbackTableView.delegate = self
        feedbackTableView.dataSource = self
        feedbackTableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == speakersTableView) {
            return presenter.getSpeakersCount();
        }
        else {
            return presenter.getFeedbackCount();
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == speakersTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(speakerCellIdentifier, forIndexPath: indexPath) as! PeopleTableViewCell
            presenter.buildSpeakerCell(cell, index: indexPath.row)
            cell.layoutMargins = UIEdgeInsetsZero
            cell.separatorInset = UIEdgeInsetsZero
            return cell
        }
        else if tableView == feedbackTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(feedbackCellIdentifier, forIndexPath: indexPath) as! FeedbackTableViewCell
            presenter.buildFeedbackCell(cell, index: indexPath.row)
            cell.layoutMargins = UIEdgeInsetsZero
            cell.separatorInset = UIEdgeInsetsZero
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        presenter.showSpeakerProfile(indexPath.row)
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
            presenter.loadFeedback()
        }
    }*/
}