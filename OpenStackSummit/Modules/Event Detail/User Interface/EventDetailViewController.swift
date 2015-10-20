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
    
    var presenter: IEventDetailPresenter! { get set }
    var eventTitle: String! { get set }
    var eventDescription: String! { get set }
    var date: String! { get set }
    var location: String! { get set }
    var allowFeedback: Bool { get set }
    var loadedAllFeedback: Bool { get set }
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
            //eventDescriptionHTML = newValue.stringByReplacingOccurrencesOfString("\\", withString: "")
            let attrStr = try! NSAttributedString(data: newValue.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
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
            moreFeedbackButton.hidden = !newValue
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
    
    var presenter: IEventDetailPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speakersTableView.delegate = self
        speakersTableView.dataSource = self
        //imageView.hnk_setImageFromURL(NSURL(string:"http://www.openstack.org/assets/paris-summit/_resampled/resizedimage464600-meridien-map-level01.png")!)
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
            let cell = tableView.dequeueReusableCellWithIdentifier(speakerCellIdentifier, forIndexPath: indexPath) as! SpeakerTableViewCell
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
        self.presenter.showSpeakerProfile(indexPath.row)
    }
    
    func reloadFeedbackData() {
        feedbackTableView.delegate = self
        feedbackTableView.dataSource = self
        feedbackTableView.reloadData()
    }
    
    @IBAction func loadMoreFeedback(sender: AnyObject) {
        presenter.loadFeedback()
    }
}