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

@objc
public protocol IEventDetailViewController {
    func didAddEventToMySchedule(event: EventDetailDTO)
    func showErrorMessage(error: NSError)
    func reloadFeedbackData()
    func reloadSpeakersData()
    
    var presenter: IEventDetailPresenter! { get set }
    var eventTitle: String! { get set }
    var eventDescription: String! { get set }
    var date: String! { get set }
    var location: String! { get set }
    var sponsors: String! { get set }
    var summitTypes: String! { get set }
    var allowFeedback: Bool { get set }
    var loadedAllFeedback: Bool { get set }
    var hasSpeakers: Bool { get set }
    var hasAnyFeedback: Bool { get set }
    var scheduled: Bool { get set }
    var myFeedbackRate: Double { get set }
    var myFeedbackReview: String! { get set }
    var myFeedbackDate: String! { get set }
    var hasMyFeedback: Bool { get set}
}

class EventDetailViewController: UIViewController, IEventDetailViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var eventDetailLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var speakersTableView: UITableView!
    @IBOutlet weak var feedbackTableView: UITableView!
    @IBOutlet weak var moreFeedbackButton: UIButton!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var sponsorsLabel: UILabel!
    @IBOutlet weak var summitTypesLabel: UILabel!
    @IBOutlet weak var summitTypesView: UIView!
    @IBOutlet weak var summitTypesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sponsorsLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scheduledButton: UIBarButtonItem!
    @IBOutlet weak var speakersHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var myFeedbackView: UIView!
    @IBOutlet weak var myFeedbackDateLabel: UILabel!
    @IBOutlet weak var myFeedbackReviewLabel: UILabel!
    @IBOutlet weak var myFeedbackRateView: CosmosView!
    @IBOutlet weak var feedbackButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var myFeedbackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var feedbackTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreFeedbackButtonHeightConstraint: NSLayoutConstraint!
    
    private var eventDescriptionHTML = ""
    private var speakerCellIdentifier = "speakerTableViewCell"
    private var feedbackCellIdentifier = "feedbackTableViewCell"
    private let borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    private let borderWidth = 1
    private var scheduledInternal = false
    
    var eventTitle: String! {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    var eventDescription: String! {
        get {
            return eventDescriptionHTML
        }
        set {
            eventDescriptionHTML = String(format:"<span style=\"font-family: Arial; font-size: 13\">%@</span>",newValue)
            let attrStr = try! NSAttributedString(data: eventDescriptionHTML.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            eventDetailLabel.attributedText = attrStr
            eventDetailLabel.sizeToFit()
        }
    }
    var date: String! {
        get {
            return timeLabel.text
        }
        set {
            timeLabel.text = newValue
        }
    }
    
    var location: String! {
        get {
            return locationLabel.text
        }
        set {
            locationLabel.text = newValue
        }
    }

    var sponsors: String! {
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
    
    var summitTypes: String! {
        get {
            return summitTypesLabel.text
        }
        set {
            summitTypesLabel.text = newValue
        }
    }
    
    var allowFeedback: Bool {
        get {
            return feedbackButtonHeightConstraint.constant > 0
        }
        set {
            feedbackButtonHeightConstraint.constant = newValue ? 30 : 0
            feedbackTableHeightConstraint.constant =  newValue ? 30 : 0
            feedbackButton.updateConstraints()
            feedbackTableView.updateConstraints()
        }
    }
    
    var loadedAllFeedback: Bool {
        get {
            return moreFeedbackButtonHeightConstraint.constant == 0
        }
        set {
            moreFeedbackButtonHeightConstraint.constant = newValue ? 0 : 30
            moreFeedbackButton.updateConstraints()
        }
    }
    
    var hasSpeakers: Bool {
        get {
            return speakersHeightConstraint.constant > 0
        }
        set {
            speakersHeightConstraint.constant = newValue ? CGFloat(presenter.getSpeakersCount() * 79) : 0
            speakersTableView.updateConstraints()
        }
    }
    
    var hasAnyFeedback: Bool  {
        get {
            return moreFeedbackButtonHeightConstraint.constant > 0
        }
        set {
            moreFeedbackButtonHeightConstraint.constant = newValue ? 30 : 0
            feedbackTableHeightConstraint.constant =  newValue ? 200 : 0
            moreFeedbackButton.updateConstraints()
            feedbackTableView.updateConstraints()
        }
    }
    
    var scheduled: Bool  {
        get {
            return scheduledInternal
        }
        set {
            scheduledInternal = newValue
            if (scheduledInternal) {
                scheduledButton.image = UIImage(named:"checked_active")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            }
            else {
                scheduledButton.image = UIImage(named:"checked_active")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            }
        }
    }
    
    var myFeedbackRate: Double{
        get {
            return myFeedbackRateView.rating
        }
        set {
            myFeedbackRateView.rating = newValue
        }
    }
    
    var myFeedbackReview: String!{
        get {
            return myFeedbackReviewLabel.text
        }
        set {
            myFeedbackReviewLabel.text = newValue
        }
    }
    
    var myFeedbackDate: String!{
        get {
            return myFeedbackDateLabel.text
        }
        set {
            myFeedbackDateLabel.text = newValue
        }
    }
    
    var hasMyFeedback: Bool {
        get {
            return feedbackButtonHeightConstraint.constant > 0
        }
        set {
            feedbackButtonHeightConstraint.constant = newValue ? 0 : 30
            myFeedbackViewHeightConstraint.constant = newValue ? 83 : 0
            feedbackButton.updateConstraints()
            myFeedbackView.updateConstraints()
        }
    }
    
    var presenter: IEventDetailPresenter!
    
    override func viewWillAppear(animated: Bool) {
        presenter.viewLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduledButton.width = 10
        scheduledButton.action = Selector("toggleSchedule:")
        
        feedbackButton.layer.cornerRadius = 10
        moreFeedbackButton.layer.cornerRadius = 10

        timeView.addBottomBorderWithColor(borderColor, width: CGFloat(borderWidth))
        locationView.addBottomBorderWithColor(borderColor, width: CGFloat(borderWidth))
        summitTypesView.addTopBorderWithColor(borderColor, width: CGFloat(borderWidth))
        summitTypesView.addBottomBorderWithColor(borderColor, width: CGFloat(borderWidth))
        myFeedbackView.addTopBorderWithColor(borderColor, width: CGFloat(borderWidth))
        myFeedbackView.addBottomBorderWithColor(borderColor, width: CGFloat(borderWidth))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didAddEventToMySchedule(event: EventDetailDTO) {
        
    }
    
    func showErrorMessage(error: NSError) {
        
    }
    
    @IBAction func leaveFeedback(sender: AnyObject) {
        presenter.leaveFeedback()
    }
    
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
        if (tableView == speakersTableView) {
            let cell = tableView.dequeueReusableCellWithIdentifier(speakerCellIdentifier, forIndexPath: indexPath) as! PersonTableViewCell
            presenter.buildSpeakerCell(cell, index: indexPath.row)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(feedbackCellIdentifier, forIndexPath: indexPath) as! FeedbackGivenTableViewCell
            presenter.buildFeedbackCell(cell, index: indexPath.row)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        presenter.showSpeakerProfile(indexPath.row)
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
    
    @IBAction func showLocation(sender: UITapGestureRecognizer) {
        presenter.showVenueDetail()
    }
    
    @IBAction func loadMoreFeedback(sender: AnyObject) {
        presenter.loadFeedback()
    }
    
    @IBAction func toggleSchedule(sender: UIBarButtonItem) {
        presenter.toggleScheduledStatus()
    }
    
    override func viewWillDisappear(animated: Bool) {
        presenter.viewUnload()
    }
}