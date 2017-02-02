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
import XCDYouTubeKit
    
final class EventDetailViewController: UITableViewController, ShowActivityIndicatorProtocol, MessageEnabledViewController, TextViewController, ContextMenuViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) var feedBackHeader: EventFeedbackHeader!
    
    // MARK: - Properties
    
    var event: Identifier!
    
    // MARK: - Private Properties
    
    private var eventCache: Event!
    
    private var eventDetail: EventDetail!
    
    private var data = [Detail]()
    
    private var entityController: EntityController<Event>!
    
    private var scheduled = false
    
    private var addToScheduleInProgress = false
    private var shouldShowReviews = false
    private var loadingFeedback = false
    private var loadingAverageRating = false
    private var feedbackList = [FeedbackDetail]()
    private var loadedAllFeedback = false
    private var currentFeedbackPage: Page<Review>?
    
    var contextMenu: ContextMenu {
        
        let message = "Check out this #OpenStack session I’m attending at the #OpenStackSummit!"
        
        let url = eventDetail.webpageURL
        
        var actions: [ContextMenu.Action] = []
        
        if self.data.contains(.feedback) {
            
            let rate = ContextMenu.Action(activityType: "\(self.dynamicType).Rate", image: nil, title: "Rate", handler: .background({ [weak self] (didComplete) in
                
                guard let controller = self else { return }
                
                let feedbackVC = R.storyboard.feedback.feedbackEditViewController()!
                
                feedbackVC.event = controller.event
                
                feedbackVC.rate = 0
                
                controller.showViewController(feedbackVC, sender: self)
                
                didComplete(true)
            }))
            
            actions.append(rate)
        }
        
        let isAttendee = Store.shared.isLoggedInAndConfirmedAttendee
        
        if isAttendee && addToScheduleInProgress == false {
            
            let title = scheduled ? "Remove from Schedule" : "Add to Schedule"
            
            let scheduleEvent = ContextMenu.Action(activityType: "\(self.dynamicType).ScheduleEvent", image: nil, title: title, handler: .background({ [weak self] (didComplete) in
                
                guard let controller = self else { return }
                
                controller.toggleSchedule()
                
                didComplete(true)
            }))
            
            actions.append(scheduleEvent)
        }
        
        return ContextMenu(actions: actions, shareItems: [message, url])
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addContextMenuBarButtonItem()
        
        // setup tableview
        tableView.registerNib(R.nib.feedbackTableViewCell)
        tableView.registerNib(R.nib.detailImageTableViewCell)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        // entityController 
        entityController = EntityController(identifier: event, entity: EventManagedObject.self, context: Store.shared.managedObjectContext)
        
        entityController.event.updated = { [weak self] _ in
            
            guard let controller = self else { return }
            
            guard controller.loadingFeedback == false && controller.loadingAverageRating == false
                else { return }
            
            controller.updateUI()
        }
        
        entityController.event.deleted = { [weak self] _ in
            
            guard let controller = self else { return }
            
            controller.updateUI()
        }
        
        self.updateUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // handoff
        self.userActivity?.becomeCurrent()
        
        // update UI
        self.updateUI()
        tableView.tableFooterView = UIView()
        
        // dont continue if no connectivity
        guard Reachability.connected else { return }
        
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
    
    @IBAction func rsvp(sender: AnyObject? = nil) {
        
        guard let url = NSURL(string: eventDetail.rsvp)
            else { return }
        
        UIApplication.sharedApplication().openURL(url)
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        guard let event = self.event
            else { fatalError("No identifier set") }
        
        let context = Store.shared.managedObjectContext
        
        // handle event deletion
        guard let eventManagedObject = try! EventManagedObject.find(event, context: context) else {
            
            self.view.userInteractionEnabled = false
            self.navigationItem.rightBarButtonItems = []
            showErrorAlert("The event has been deleted.",
                           okHandler: { self.navigationController?.popToRootViewControllerAnimated(true) })
            return
        }
        
        self.eventCache = Event(managedObject: eventManagedObject)
        self.eventDetail = EventDetail(managedObject: eventManagedObject)
        
        self.data = [.title]
        
        if eventDetail.video != nil {
            
            data.append(.video)
        }
        
        // Can give feedback after event started, and if there is no feedback for that user
        if let member = Store.shared.authenticatedMember
            where eventCache.start < Date()
            && (try! context.managedObjects(MemberFeedbackManagedObject.self, predicate: NSPredicate(format: "event == %@ AND member == %@", eventManagedObject, member))).isEmpty &&
            (try! context.managedObjects(ReviewManagedObject.self, predicate: NSPredicate(format: "event == %@ AND member == %@", eventManagedObject, member))).isEmpty {
            
            data.append(.feedback)
        }
        
        data.append(.date)
        
        if eventDetail.location.isEmpty == false {
            
            data.append(.location)
        }
                
        if eventDetail.tags.isEmpty == false {
            
            data.append(.tags)
        }
        
        data.append(.description)
        
        if eventDetail.level.isEmpty == false {
            
            data.append(.level)
        }
        
        // configure bar button items
        let isAtteendee = Store.shared.isLoggedInAndConfirmedAttendee
        
        if isAtteendee {
            
            self.scheduled = Store.shared.isEventScheduledByLoggedMember(event: event)
        }
        
        // get all reviews for this event
        let reviews = try! context.managedObjects(ReviewManagedObject.self, predicate: NSPredicate(format: "event == %@", eventManagedObject), sortDescriptors: FeedbackManagedObject.sortDescriptors)
        
        let attendeeFeedback = try! context.managedObjects(MemberFeedbackManagedObject.self, predicate: NSPredicate(format: "event == %@", eventManagedObject), sortDescriptors: FeedbackManagedObject.sortDescriptors)
        
        shouldShowReviews = eventCache.start < Date() && (reviews.count + attendeeFeedback.count) > 0
        
        feedbackList = reviews.map { FeedbackDetail(managedObject: $0) }
        
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
        
        Store.shared.feedback(self.eventDetail.summit, event: self.event, page: nextPage, objectsPerPage: 5) { [weak self] (response) in
            
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
        
        let summit = eventCache.summit
        
        Store.shared.averageFeedback(summit, event: event) { [weak self] (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                controller.loadingAverageRating = false
                
                switch response {
                    
                case let .Error(error):
                    
                    controller.showErrorMessage(error)
                    
                case .Value:
                    
                    controller.configureAverageRatingView()
                }
            }
        }
    }
    
    private func toggleSchedule() {
        
        let oldValue = self.scheduled
        
        if addToScheduleInProgress {
            return
        }
        
        addToScheduleInProgress = true
        
        // update UI
        self.scheduled = !oldValue
        
        let completion: ErrorType? -> () = { [weak self] (response) in
            
            guard let controller = self else { return }
            
            controller.addToScheduleInProgress = false
            
            switch response {
                
            case let .Some(error):
                
                // restore original value
                controller.scheduled = oldValue
                
                // show error
                controller.showErrorMessage(error as NSError)
                
            case .None: break
            }
        }
        
        if oldValue {
            
            Store.shared.removeEventFromSchedule(self.eventDetail.summit, event: self.event, completion: completion)
            
        } else {
            
            Store.shared.addEventToSchedule(self.eventDetail.summit, event: self.event, completion: completion)
        }
    }
    
    private func configure(cell cell: PeopleTableViewCell, at indexPath: NSIndexPath) {
        
        assert(indexPath.section == Section.speakers.rawValue, "\(indexPath.section) is not speaker section")
        
        let speaker = eventDetail.speakers[indexPath.row]
        cell.name = speaker.name
        cell.title = speaker.title
        cell.pictureURL = speaker.pictureURL
        cell.isModerator = speaker.isModerator
        
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
        case .speakers: return eventDetail.speakers.count
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
                if let data = eventDescriptionHTML.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false),
                    let attrStr = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
                    
                    cell.descriptionTextView.attributedText = attrStr
                    
                } else {
                    
                    cell.descriptionTextView.text = ""
                }
                
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
            
            let memberVC = MemberProfileViewController(profile: MemberProfileIdentifier.speaker(speaker.identifier))
            
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
