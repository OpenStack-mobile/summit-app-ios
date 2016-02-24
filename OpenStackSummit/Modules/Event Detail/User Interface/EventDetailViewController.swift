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

@objc
public protocol IEventDetailViewController : IScheduleableView, IMessageEnabledViewController {
    func reloadFeedbackData()
    func reloadSpeakersData()
    func showFeedbackListActivityIndicator()
    func hideFeedbackListActivityIndicator()
    func showActivityIndicator()
    func hideActivityIndicator()
    
    var navigationController: UINavigationController? { get }
    var presenter: IEventDetailPresenter! { get set }
    var eventTitle: String! { get set }
    var eventDescription: String! { get set }
    var date: String! { get set }
    var location: String! { get set }
    var sponsors: String! { get set }
    var summitTypes: String! { get set }
    var tags: String! { get set }
    var allowFeedback: Bool { get set }
    var hasSpeakers: Bool { get set }
    var hasAnyFeedback: Bool { get set }
    var myFeedbackRate: Double { get set }
    var myFeedbackReview: String! { get set }
    var myFeedbackDate: String! { get set }
    var myFeedbackName: String! { get set }
    var hasMyFeedback: Bool { get set}
    var isScheduledStatusVisible: Bool { get set }
    var level: String! { get set }
    var track: String! { get set }
}

class EventDetailViewController: BaseViewController, IEventDetailViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var feedbackListActivityIndicator: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var eventDetailLabel: UILabel!
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
    @IBOutlet weak var myFeedbackView: UIView!
    @IBOutlet weak var myFeedbackDateLabel: UILabel!
    @IBOutlet weak var myFeedbackReviewLabel: UILabel!
    @IBOutlet weak var myFeedbackRateView: CosmosView!
    @IBOutlet weak var myFeedbackNameLabel: UILabel!
    @IBOutlet weak var feedbackButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var myFeedbackViewHeightConstraint: NSLayoutConstraint!
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
    
    private var eventDescriptionHTML = ""
    private var speakerCellIdentifier = "speakerTableViewCell"
    private var feedbackCellIdentifier = "feedbackTableViewCell"
    private let borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    private let borderWidth = 1
    private var scheduledInternal = false
    private var actionSheet: AHKActionSheet!
    
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
            if (newValue == nil || newValue.isEmpty) {
                locationViewHeightConstraint.constant = 0
            }
            else {
                locationViewHeightConstraint.constant = 60
            }
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
    
    var tags: String! {
        get {
            return tagsLabel.text
        }
        set {
            tagsLabel.text = newValue
            tagsViewHeightConstraint.constant = newValue == nil || newValue.isEmpty ? 0 : 60
            tagsView.updateConstraints()
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
            navigationItem.rightBarButtonItems![0].image = newValue ? UIImage(named:"Submenu_Feedback") : nil
            navigationItem.rightBarButtonItems![0].enabled = newValue
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
            return feedbackTableHeightConstraint.constant > 0
        }
        set {
            feedbackTableHeightConstraint.constant = newValue ? 200 : 0
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
                scheduledButton.image = UIImage(named:"unchecked")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
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

    var myFeedbackName: String!{
        get {
            return myFeedbackNameLabel.text
        }
        set {
            myFeedbackNameLabel.text = newValue
        }
    }
    
    var hasMyFeedback: Bool {
        get {
            return feedbackButtonHeightConstraint.constant > 0
        }
        
        set {
            if newValue {
                if myFeedbackViewHeightConstraint != nil {
                    myFeedbackView.removeConstraint(myFeedbackViewHeightConstraint)
                    myFeedbackViewHeightConstraint = nil                    
                }
            }
            else {
                if myFeedbackViewHeightConstraint == nil {
                    myFeedbackViewHeightConstraint = NSLayoutConstraint(item: myFeedbackView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0)
                    myFeedbackView.addConstraint(myFeedbackViewHeightConstraint)
                }
            }
            myFeedbackView.updateConstraints()
        }
    }
    
    var isScheduledStatusVisible: Bool {
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
    
    var level: String! {
        get {
            return levelLabel.text
        }
        set {
            levelLabel.text = newValue
            levelLabelHeightConstraint.constant = newValue == nil || newValue.isEmpty ? 0 : 60
            levelLabel.updateConstraints()
        }
    }
    
    var track: String! {
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
    
    var presenter: IEventDetailPresenter!
    
    override func viewWillAppear(animated: Bool) {
        presenter.viewLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if tableView == speakersTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(speakerCellIdentifier, forIndexPath: indexPath) as! PeopleTableViewCell
            presenter.buildSpeakerCell(cell, index: indexPath.row)
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

/*    @IBAction func showSubmenu(sender: UIBarButtonItem) {
        actionSheet.show()
    }*/
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            presenter.loadFeedback()
        }
    }
    
    func showFeedbackListActivityIndicator() {
        feedbackListActivityIndicator.hidden = false
    }
    
    func hideFeedbackListActivityIndicator() {
        feedbackListActivityIndicator.hidden = true
    }
    
    func showActivityIndicator() {
        SwiftSpinner.show("Please wait...")
    }
    
    func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
}