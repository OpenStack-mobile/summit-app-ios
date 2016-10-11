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
import SwiftFoundation
import CoreSummit
import RealmSwift
import XCDYouTubeKit
    
final class EventDetailViewController: UITableViewController, ShowActivityIndicatorProtocol, MessageEnabledViewController, TextViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var scheduledButton: UIBarButtonItem!
    @IBOutlet private(set) var feedBackHeader: EventFeedbackHeader!
    
    // MARK: - Properties
    
    var event: Identifier! {
        
        didSet { if isViewLoaded() { updateUI() } }
    }
    
    // MARK: - Private Properties
    
    private var eventCache: Event!
    
    private var eventDetail: EventDetail!
    
    private var data = [Detail]()
    
    private var notificationToken: RealmSwift.NotificationToken?
    
    private var scheduled = false {
        
        didSet {
            
            let image = scheduled ? R.image.checked_active()! : R.image.unchecked()!
            
            scheduledButton.image = image.imageWithRenderingMode(.AlwaysOriginal)
        }
    }
    
    private var shouldShowReviews = false
    private var loadingFeedback = false
    private var loadingAverageRating = false
    private var feedbackList = [FeedbackDetail]()
    private var loadedAllFeedback = false
    private var currentFeedbackPage: Page<Review>?
    
    // MARK: - Loading
    
    deinit {
        
        notificationToken?.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup tableview
        tableView.registerNib(R.nib.feedbackTableViewCell)
        tableView.registerNib(R.nib.detailImageTableViewCell)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        // update from Realm
        notificationToken = Store.shared.realm.addNotificationBlock { [weak self] _ in
            
            guard let controller = self else { return }
            
            guard controller.loadingFeedback == false && controller.loadingAverageRating == false
                else { return }
            
            controller.updateUI()
        
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // handoff
        self.userActivity?.becomeCurrent()
        
        // update UI
        self.updateUI()
        tableView.tableFooterView = UIView()
        
        // load feedback
        loadAverageRating()
        loadFeedback()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 9.0, *) {
            self.userActivity?.resignCurrent()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func playVideo(sender: UIButton) {
        
        assert(eventDetail.video != nil, "No video")
        
        self.playVideo(eventDetail.video!)
    }
    
    @IBAction func rsvp(sender: UIButton) {
        
        guard let url = NSURL(string: eventDetail.rsvp)
            else { return }
        
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func share(sender: UIBarButtonItem) {
        
        let activityViewController = UIActivityViewController(activityItems: [eventDetail.webpageURL], applicationActivities: nil)
        activityViewController.modalPresentationStyle = .Popover
        activityViewController.popoverPresentationController?.barButtonItem = sender
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func toggleSchedule(sender: UIBarButtonItem) {
        
        let oldValue = self.scheduled
        
        // update UI
        self.scheduled = !oldValue
        
        let completion: ErrorValue<()> -> () = { [weak self] (response) in
            
            guard let controller = self else { return }
            
            switch response {
                
            case let .Error(error):
                
                // restore original value
                controller.scheduled = oldValue
                
                // show error
                controller.showErrorMessage(error as NSError)
                
            case .Value(): break
            }
        }
        
        if oldValue {
            
            Store.shared.removeEventFromSchedule(event: self.event, completion: completion)
            
        } else {
            
            Store.shared.addEventToSchedule(event: self.event, completion: completion)
        }
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        assert(event != nil, "No identifier set")
        
        // handle event deletion
        guard let realmEvent = RealmSummitEvent.find(event, realm: Store.shared.realm) else {
            
            self.view.userInteractionEnabled = false
            self.navigationItem.rightBarButtonItems = []
            showErrorAlert("The event has been deleted.",
                           okHandler: { self.navigationController?.popToRootViewControllerAnimated(true) })
            return
        }
        
        self.eventCache = Event(realmEntity: realmEvent)
        self.eventDetail = EventDetail(realmEntity: realmEvent)
        
        self.data = [.title]
        
        if eventDetail.video != nil {
            
            data.append(.video)
        }
        
        // Can give feedback after event started, and if there is no feedback for that user
        if let attendee = Store.shared.authenticatedMember?.attendeeRole
            where eventCache.start < Date() &&
            Store.shared.realm.objects(RealmAttendeeFeedback).filter("event.id = %@ AND attendee.id = %@", event, attendee.id).isEmpty &&
            Store.shared.realm.objects(RealmReview).filter("event.id = %@ AND attendeeId = %@", event, attendee.id).isEmpty {
            
            data.append(.feedback)
        }
        
        data += [.date, .location]
        
        if eventDetail.tags.isEmpty == false {
            
            data.append(.tags)
        }
        
        data.append(.description)
                
        if eventDetail.summitTypes.isEmpty == false {
            
            data.append(.summitTypes)
        }
        
        if eventDetail.level.isEmpty == false {
            
            data.append(.level)
        }
        
        // configure bar button items
        let isAtteendee = Store.shared.isLoggedInAndConfirmedAttendee
        self.scheduledButton.enabled = isAtteendee
        
        if isAtteendee {
            
            self.scheduled = Store.shared.isEventScheduledByLoggedMember(event: event)
            
        } else {
            
            self.scheduledButton.image = nil
        }
        
        // get all reviews for this event
        let realmFeedback = Array(Store.shared.realm.objects(RealmReview).filter("event.id == %@", event))
        
        let attendeeFeedback = Store.shared.realm.objects(RealmAttendeeFeedback).filter("event.id = %@", event)
        
        shouldShowReviews = eventCache.start < Date() && (realmFeedback.count + attendeeFeedback.count) > 0
        
        feedbackList = realmFeedback.map { FeedbackDetail(realmEntity: $0) }
        
        // configure feedback view
        configureReviewCountView()
        configureAverageRatingView()
        
        // reload table
        self.tableView.reloadData()
        
        // set user activity for handoff
        let userActivity = NSUserActivity(activityType: AppActivity.view.rawValue)
        userActivity.title = eventDetail.name
        userActivity.webpageURL = eventDetail.webpageURL
        userActivity.userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.event.rawValue, AppActivityUserInfo.identifier.rawValue: self.event]
        
        self.userActivity = userActivity
    }
    
    private func loadFeedback() {
        
        guard loadingFeedback == false && loadedAllFeedback == false
            else { return }
        
        loadingFeedback = true
        
        configureReviewCountView()
        
        let nextPage = (currentFeedbackPage?.currentPage ?? 0) + 1
        
        Store.shared.feedback(event: event, page: nextPage, objectsPerPage: 5) { [weak self] (response) in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                guard let controller = self else { return }
                
                assert(controller.loadingFeedback)
                
                controller.loadingFeedback = false
                
                switch response {
                    
                case let .Error(error):
                    
                    print("Error loading feedback: \(error)")
                    
                case let .Value(feedbackPage):
                    
                    controller.currentFeedbackPage = feedbackPage
                    controller.loadedAllFeedback = feedbackPage.items.isEmpty
                    controller.updateUI()
                }
            }
        }
    }
    
    private func loadAverageRating() {
        
        guard loadingAverageRating == false
            else { return }
        
        loadingAverageRating = true
        
        configureAverageRatingView()
        
        Store.shared.averageFeedback(event: event) { [weak self] (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                controller.loadingAverageRating = false
                
                switch response {
                    
                case let .Error(error):
                    
                    controller.showErrorMessage(error as NSError)
                    
                case .Value:
                    
                    controller.configureAverageRatingView()
                }
            }
        }
    }
    
    private func configure(cell cell: PeopleTableViewCell, at indexPath: NSIndexPath) {
        
        assert(indexPath.section == Section.speakers.rawValue, "\(indexPath.section) is not speaker section")
        
        let speaker = eventDetail.speakers[indexPath.row]
        cell.name = speaker.name
        cell.title = speaker.title
        cell.pictureURL = speaker.pictureURL
        cell.isModerator = eventDetail.moderator != nil && speaker.identifier == eventDetail.moderator?.identifier
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
    }
    
    private func configure(cell cell: FeedbackTableViewCell, at indexPath: NSIndexPath) {
        
        assert(indexPath.section == Section.feedback.rawValue, "\(indexPath.section) is not feedback section")
        
        let feedback = feedbackList[indexPath.row]
        
        cell.eventName = ""
        cell.owner = feedback.owner
        cell.rate = Double(feedback.rate)
        cell.review = feedback.review
        cell.date = feedback.date
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
    }
    
    private func configureAverageRatingView() {
        
        feedBackHeader.averageRatingView.hidden = loadingAverageRating
        feedBackHeader.averageRatingView.rating = eventCache.averageFeedback
        feedBackHeader.averageRatingActivityIndicator.hidden = !loadingAverageRating
        
        if loadingFeedback {
            
            feedBackHeader.averageRatingActivityIndicator.startAnimating()
        } else {
            
            feedBackHeader.averageRatingActivityIndicator.stopAnimating()
        }
    }
    
    private func configureReviewCountView() {
        
        if loadingFeedback {
            
            feedBackHeader.reviewsLabel.text = "Loading..."
            
        } else {
            
            let reviewCount = currentFeedbackPage?.total ?? 0
            
            feedBackHeader.reviewsLabel.text = "\(reviewCount) Reviews"
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return Section.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = Section(rawValue: section)!
        
        switch section {
        case .details: return data.count
        case .speakers: return eventCache.presentation?.speakers.count ?? 0
        case .feedback: return shouldShowReviews ? feedbackList.count : 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = Section(rawValue: indexPath.section)!
        
        switch section {
            
        case .details:
            
            let detail = self.data[indexPath.row]
            
            switch detail {
                
            case .title:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.eventDetailTitleTableViewCell, forIndexPath: indexPath)!
                
                // title
                cell.titleLabel.text = eventDetail.name
                
                // track
                cell.trackLabel.text = eventDetail.track
                cell.trackLabelHeightConstraint.constant = eventDetail.track.isEmpty ? 0 : 30
                cell.trackLabel.updateConstraints()
                
                return cell
                
            case .description:
                
                // description text
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.eventDetailDescriptionTableViewCell, forIndexPath: indexPath)!
                
                let eventDescriptionHTML = String(format:"<style>p:last-of-type { display:compact }</style><span style=\"font-family: Arial; font-size: 13\">%@</span>", eventDetail.eventDescription)
                let attrStr = try! NSAttributedString(data: eventDescriptionHTML.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                
                cell.descriptionTextView.attributedText = attrStr
                cell.descriptionTextView.textContainerInset = UIEdgeInsetsZero
                
                cell.descriptionTextView.delegate = self
                
                // sponsors
                
                cell.sponsorsLabel.text = eventDetail.sponsors
                cell.sponsorsLabelHeightConstraint.constant = eventDetail.sponsors.isEmpty ? 0 : 30
                cell.sponsorsLabelSeparationConstraint.constant = eventDetail.sponsors.isEmpty ? 0 : 8
                cell.sponsorsLabel.updateConstraints()
                
                // rsvp
                
                cell.rsvpButtonHeightConstraint.constant = eventDetail.rsvp.isEmpty ? 0 : 38
                cell.rsvpButtonSeparationConstraint.constant = eventDetail.rsvp.isEmpty ? 0 : 16
                cell.rsvpButton.hidden = eventDetail.rsvp.isEmpty
                cell.rsvpButton.updateConstraints()
                
                return cell
                
            case .date:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.detailImageTableViewCell, forIndexPath: indexPath)!
                
                cell.titleLabel!.text = eventDetail.dateTime
                cell.detailImageView.image = R.image.time()!
                cell.accessoryType = .None
                cell.selectionStyle = .None
                
                return cell
                
            case .tags:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.detailImageTableViewCell, forIndexPath: indexPath)!
                
                cell.titleLabel!.text = eventDetail.tags
                cell.detailImageView.image = R.image.tag()!
                cell.accessoryType = .None
                cell.selectionStyle = .None
                
                return cell
                
            case .location:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.detailImageTableViewCell, forIndexPath: indexPath)!
                
                cell.titleLabel!.text = eventDetail.location
                cell.detailImageView.image = R.image.map_pin()!
                cell.accessoryType = .DisclosureIndicator
                cell.selectionStyle = .Default
                
                return cell
                
            case .level:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.detailImageTableViewCell, forIndexPath: indexPath)!
                
                cell.titleLabel!.text = eventDetail.level
                cell.detailImageView.image = R.image.level()!
                cell.accessoryType = .None
                cell.selectionStyle = .None
                
                return cell
                
            case .summitTypes:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.detailImageTableViewCell, forIndexPath: indexPath)!
                
                cell.titleLabel!.text = eventDetail.summitTypes
                cell.detailImageView.image = R.image.credential()!
                cell.accessoryType = .None
                cell.selectionStyle = .None
                
                return cell
                
            case .video:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.eventDetailVideoTableViewCell, forIndexPath: indexPath)!
                
                cell.playButton.hidden = true
                cell.activityIndicator.hidden = false
                cell.activityIndicator.startAnimating()
                
                if let thumbnailURL = NSURL(youtubeThumbnail: eventDetail.video!.youtube) {
                    
                    cell.videoImageView.hnk_setImageFromURL(thumbnailURL, placeholder: nil, format: nil, failure: nil, success: { (image) in
                        
                        cell.videoImageView.image = image
                        cell.playButton.hidden = false
                        cell.activityIndicator.stopAnimating()
                        cell.setNeedsDisplay()
                    })
                }
                
                return cell
                
            case .feedback:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.eventDetailFeedbackTableViewCell, forIndexPath: indexPath)!
                
                cell.feedbackView.rating = 0.0
                
                cell.feedbackView.didTouchCosmos = { [weak self] (rating) in
                    
                    guard let controller = self else { return }
                    
                    cell.feedbackView.rating = rating
                    
                    let feedbackVC = R.storyboard.feedback.feedbackEditViewController()!
                    
                    feedbackVC.event = controller.event
                    
                    feedbackVC.rate = Int(rating) // prefill rating
                    
                    controller.showViewController(feedbackVC, sender: self)
                }
                
                return cell
            }
            
        case .speakers:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.speakerTableViewCell, forIndexPath: indexPath)!
            
            configure(cell: cell, at: indexPath)
            
            return cell
            
        case .feedback:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.feedbackTableViewCell, forIndexPath: indexPath)!
            
            configure(cell: cell, at: indexPath)
            
            // load feedback
            if indexPath.row == feedbackList.count - 1
                && loadingFeedback == false
                && loadedAllFeedback == false {
                
                loadFeedback()
            }
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let section = Section(rawValue: indexPath.section)!
        
        switch section {
            
        case .details:
            
            let detail = self.data[indexPath.row]
            
            switch detail {
                
            case .location:
                
                guard let venue = eventDetail.venue
                    else { return }
                
                showLocationDetail(venue)
                
            default: break
            }
            
        case .speakers:
            
            let speaker = eventDetail.speakers[indexPath.row]
            
            let memberVC = MemberProfileViewController(profile: MemberProfileIdentifier(speaker: speaker))
            
            self.showViewController(memberVC, sender: self)
            
        case .feedback: break
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        
        let section = Section(rawValue: section)!
        
        switch section {
        case .details: return 0.0
        case .speakers: return 0.0
        case .feedback: return shouldShowReviews ? 60 : 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let section = Section(rawValue: section)!
        
        switch section {
        case .details: return 0.0
        case .speakers: return 0.0
        case .feedback: return shouldShowReviews ? UITableViewAutomaticDimension : 0
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let section = Section(rawValue: section)!
        
        switch section {
            
        case .details: return UIView()
        case .speakers: return UIView()
        case .feedback: return shouldShowReviews ? feedBackHeader : nil
        }
    }
    
    // MARK: - UITextViewDelegate
    
    // Protocol extensions are not working entirely in ObjC, need to place implementation here and not in extension
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        guard self.openWebURL(URL)
            else { return true }
        
        return false
    }
}

// MARK: - Supporting Types

private extension EventDetailViewController {
    
    enum Section: Int {
        
        static let count = 3
        
        case details
        case speakers
        case feedback
    }
    
    enum Detail {
        
        case title
        case video
        case feedback
        case date
        case location
        case tags
        case description
        case summitTypes
        case level
    }
}

final class EventDetailTitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var trackLabelHeightConstraint: NSLayoutConstraint!
}

final class EventDetailVideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}

final class EventDetailDescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var sponsorsLabel: UILabel!
    @IBOutlet weak var sponsorsLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sponsorsLabelSeparationConstraint: NSLayoutConstraint!
    @IBOutlet weak var rsvpButton: UIButton!
    @IBOutlet weak var rsvpButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rsvpButtonSeparationConstraint: NSLayoutConstraint!
}

final class EventDetailFeedbackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var feedbackView: CosmosView!
}

final class EventFeedbackHeader: UIView {
    
    @IBOutlet weak var averageRatingView: CosmosView!
    @IBOutlet weak var averageRatingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reviewsLabel: UILabel!
}
