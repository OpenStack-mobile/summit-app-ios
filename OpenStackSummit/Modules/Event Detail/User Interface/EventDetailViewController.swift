//
//  EventDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Haneke

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
    var allowFeedback: Bool { get set }
    var loadedAllFeedback: Bool { get set }
    var hasSpeakers: Bool { get set }
    var hasAnyFeedback: Bool { get set }
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
    
    private var eventDescriptionHTML = ""
    private var speakerCellIdentifier = "speakerTableViewCell"
    private var feedbackCellIdentifier = "feedbackTableViewCell"
    
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
            eventDescriptionHTML = newValue
            let attrStr = try! NSAttributedString(data: eventDescriptionHTML.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            eventDetailLabel.attributedText = attrStr
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
    
    var allowFeedback: Bool {
        get {
            return !feedbackButton.hidden
        }
        set {
            feedbackButton.hidden = !newValue
            feedbackTableView.hidden = !newValue
        }
    }
    
    var loadedAllFeedback: Bool {
        get {
            return moreFeedbackButton.hidden
        }
        set {
            moreFeedbackButton.hidden = newValue
        }
    }
    
    var hasSpeakers: Bool {
        get {
            return !speakersTableView.hidden
        }
        set {
            speakersTableView.hidden = !newValue
        }
    }
    var hasAnyFeedback: Bool  {
        get {
            return !feedbackTableView.hidden
        }
        set {
            feedbackTableView.hidden = !newValue
        }
    }
    
    
    var presenter: IEventDetailPresenter!
    
    override func viewWillAppear(animated: Bool) {
        presenter.viewLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func viewWillDisappear(animated: Bool) {
        presenter.viewUnload()
    }
}