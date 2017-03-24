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
import SwiftFoundation
import CoreSummit
import XCDYouTubeKit
import EventKit
import JGProgressHUD
    
final class EventDetailViewController: UITableViewController, EventViewController, ActivityViewController, MessageEnabledViewController, TextViewController, ContextMenuViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) var titleHeader: EventDetailTitleHeader!
    @IBOutlet private(set) var feedBackHeader: EventDetailFeedbackHeader!
    @IBOutlet private(set) var speakersHeader: EventDetailHeader!
    
    // MARK: - Properties
    
    var event: Identifier!
    
    var eventRequestInProgress = false
    
    lazy var eventStore: EKEventStore = EKEventStore()
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .Dark)
    
    // MARK: - Private Properties
    
    private var eventCache: Event!
    private var eventDetail: EventDetail!
    private var data = [Detail]()
    private var entityController: EntityController<Event>!
    
    private var shouldShowReviews = false
    private var loadingFeedback = false
    private var loadingAverageRating = false
    private var feedbackList = [FeedbackDetail]()
    private var loadedAllFeedback = false
    private var currentFeedbackPage: Page<Feedback>?
    
    var contextMenu: ContextMenu { return contextMenu(for: eventDetail) }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addContextMenuBarButtonItem()
        
        // setup tableview
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
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
        
        entityController.enabled = true
        
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
        
        self.userActivity?.resignCurrent()
    }
    
    override func updateUserActivityState(userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.event.rawValue,
                        AppActivityUserInfo.identifier.rawValue: self.event]
        
        userActivity.addUserInfoEntriesFromDictionary(userInfo as [NSObject : AnyObject])
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Actions
    
    @IBAction func playVideo(sender: UIButton) {
        
        assert(eventDetail.video != nil, "No video")
        
        self.playVideo(eventDetail.video!)
    }
    
    @IBAction func favoriteAction(sender: UIButton) {
        
        guard eventRequestInProgress == false else { return }
        
        guard Store.shared.isLoggedIn
            else { showErrorAlert("Login to use this function"); return }
        
        self.toggleFavorite(for: eventDetail)
    }
    
    @IBAction func scheduleAction(sender: UIButton) {
        
        guard eventRequestInProgress == false else { return }
        
        guard Store.shared.isLoggedInAndConfirmedAttendee
            else { showErrorAlert("Only attendees can use this function. Enter your EventBrite order number in my summit if you are an attendee."); return }
        
        self.toggleScheduledStatus(for: eventDetail)
    }
    
    @IBAction func rateAction(sender: UIButton) {
        
        guard Store.shared.isLoggedIn
            else { showErrorAlert("Login to use this function"); return }
        
        let feedbackViewController = R.storyboard.feedback.feedbackEditViewController()!
        
        feedbackViewController.event = event
        
        feedbackViewController.rate = 0
        
        self.showViewController(feedbackViewController, sender: self)
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
        
        self.data = []
        
        if eventDetail.video != nil {
            
            self.data.append(.video)
        }
        
        self.data.append(.description)
        
        if eventDetail.location.isEmpty == false {
            
            data.append(.location)
        }
        
        if eventDetail.level.isEmpty == false {
            
            data.append(.level)
        }
        
        // configure title header
        
        titleHeader.titleLabel.text = eventDetail.name
        titleHeader.trackLabel.text = eventDetail.track
        titleHeader.trackLabel.textColor = UIColor(hexString: eventDetail.trackGroupColor) ?? .whiteColor()
        titleHeader.trackLabel.hidden = eventDetail.track.isEmpty
        
        let didConfirm = Store.shared.isEventScheduledByLoggedMember(event: event)
        let isFavorite = Store.shared.authenticatedMember?.isFavorite(event: event) ?? false
        
        titleHeader.scheduleButton.highlighted = didConfirm
        titleHeader.favoriteButton.highlighted = isFavorite
        
        // action buttons
        
        // get all reviews for this event
        let reviews = try! context.managedObjects(FeedbackManagedObject.self, predicate: NSPredicate(format: "event == %@", eventManagedObject), sortDescriptors: FeedbackManagedObject.sortDescriptors)
        
        shouldShowReviews = eventCache.start < Date() && reviews.isEmpty == false
        
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
        userActivity.requiredUserInfoKeys = [AppActivityUserInfo.type.rawValue, AppActivityUserInfo.identifier.rawValue]
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
    
    private func configure(cell cell: EventDetailFeedbackTableViewCell, at indexPath: NSIndexPath) {
        
        assert(indexPath.section == Section.feedback.rawValue, "\(indexPath.section) is not feedback section")
        
        let feedback = feedbackList[indexPath.row]
        
        cell.ratingView.rating = Double(feedback.rate)
        cell.reviewLabel.text = feedback.review
        cell.dateLabel.text = feedback.date
    }
    
    private func configureAverageRatingView() {
        
        feedBackHeader.averageRatingLabel.hidden = loadingAverageRating
        feedBackHeader.averageRatingView.hidden = loadingAverageRating
        feedBackHeader.averageRatingLabel.text = "\(eventCache.averageFeedback)"
        feedBackHeader.averageRatingView.rating = eventCache.averageFeedback
        feedBackHeader.averageRatingActivityIndicator.hidden = loadingAverageRating == false
        
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
                
            case .video:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.eventDetailVideoTableViewCell, forIndexPath: indexPath)!
                
                guard let video = self.eventDetail?.video
                    else { fatalError("Event has no video") }
                
                cell.videoImageView.image = nil
                cell.playButton.hidden = true
                cell.activityIndicator.hidden = false
                cell.activityIndicator.startAnimating()
                
                guard let thumbnailURL = NSURL(youtubeThumbnail: video.youtube)
                    else { return cell }
                
                cell.videoImageView.hnk_setImageFromURL(thumbnailURL, success: { (image) in
                    
                    cell.playButton.hidden = false
                    cell.activityIndicator.hidden = true
                    cell.activityIndicator.stopAnimating()
                    cell.videoImageView.image = image
                })
                
                return cell
                
            case .description:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.eventDetailDescriptionTableViewCell, forIndexPath: indexPath)!
                
                // date and time
                
                cell.eventDayLabel.text = eventDetail.day
                cell.eventTimeLabel.text = eventDetail.time
                
                // video
                
                cell.playButton.hidden = eventDetail.willRecord == false
                
                // description text
                
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
                
                return cell
                
            case .location:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.eventDetailTableViewCell, forIndexPath: indexPath)!
                
                cell.sectionLabel.text = "VENUE"
                cell.valueLabel.text = eventDetail.location
                
                return cell
                
            case .level:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.eventDetailTableViewCell, forIndexPath: indexPath)!
                
                cell.sectionLabel.text = "LEVEL"
                cell.valueLabel.text = eventDetail.level
                
                return cell
            }
            
        case .speakers:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.speakerTableViewCell, forIndexPath: indexPath)!
            
            configure(cell: cell, at: indexPath)
            
            return cell
            
        case .feedback:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.eventDetailFeedbackTableViewCell, forIndexPath: indexPath)!
            
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
                
                showLocationDetail(venue.identifier)
                
            case .level:
                
                let levelScheduleViewController = R.storyboard.schedule.levelScheduleViewController()!
                
                levelScheduleViewController.level = eventDetail.level
                
                self.showViewController(levelScheduleViewController, sender: self)
                
            default: break
            }
            
        case .speakers:
            
            let speaker = eventDetail.speakers[indexPath.row]
            
            let memberViewController = MemberProfileViewController(profile: PersonIdentifier.speaker(speaker.identifier))
            
            self.showViewController(memberViewController, sender: self)
            
        case .feedback:
            
            let feedback = feedbackList[indexPath.row]
            
            let memberViewController = MemberProfileViewController(profile: PersonIdentifier(member: feedback.member))
            
            self.showViewController(memberViewController, sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        
        let section = Section(rawValue: section)!
        
        switch section {
        case .details: return EventDetailTitleHeader.estimatedHeight
        case .speakers: return eventDetail.speakers.isEmpty ? 0 : EventDetailHeader.height
        case .feedback: return shouldShowReviews ? EventDetailFeedbackHeader.height : 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let section = Section(rawValue: section)!
        
        switch section {
        case .details: return UITableViewAutomaticDimension
        case .speakers: return eventDetail.speakers.isEmpty ? 0 : EventDetailHeader.height
        case .feedback: return shouldShowReviews ? EventDetailFeedbackHeader.height : 0
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let section = Section(rawValue: section)!
        
        switch section {
            
        case .details: return titleHeader
        case .speakers: return eventDetail.speakers.isEmpty ? nil : speakersHeader
        case .feedback: return shouldShowReviews ? feedBackHeader : nil
        }
    }
    
    // MARK: - UITextViewDelegate
    
    // Swift Protocol extensions are not visible to ObjC, need to place implementation here and not in extension
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
        
        case video
        case description
        case location
        case level
    }
}

final class EventDetailActionButton: Button {
    
    
}

final class EventDetailTitleHeader: UIView {
    
    static let estimatedHeight: CGFloat = 200.0
    
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var trackLabel: UILabel!
    
    @IBOutlet private(set) weak var favoriteButton: EventDetailActionButton!
    @IBOutlet private(set) weak var scheduleButton: EventDetailActionButton!
    @IBOutlet private(set) weak var rateButton: EventDetailActionButton!
}

final class EventDetailHeader: UIView {
    
    static let height: CGFloat = 60.0
    
    @IBOutlet private(set) weak var label: UILabel!
}

final class EventDetailFeedbackHeader: UIView {
    
    static let height: CGFloat = 60.0
    
    @IBOutlet private(set) weak var reviewsLabel: UILabel!
    @IBOutlet private(set) weak var averageRatingView: CosmosView!
    @IBOutlet private(set) weak var averageRatingLabel: UILabel!
    @IBOutlet private(set) weak var averageRatingActivityIndicator: UIActivityIndicatorView!
}

final class EventDetailVideoTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var videoImageView: UIImageView!
    @IBOutlet private(set) weak var playButton: UIButton!
    @IBOutlet private(set) weak var activityIndicator: UIActivityIndicatorView!
}

final class EventDetailDescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var eventDayLabel: UILabel!
    @IBOutlet private(set) weak var eventTimeLabel: UILabel!
    @IBOutlet private(set) weak var playButton: Button!
    @IBOutlet private(set) weak var descriptionTextView: UITextView!
    @IBOutlet private(set) weak var sponsorsLabel: UILabel!
    @IBOutlet private(set) weak var sponsorsLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var sponsorsLabelSeparationConstraint: NSLayoutConstraint!
}

final class EventDetailTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var sectionLabel: UILabel!
    
    @IBOutlet private(set) weak var valueLabel: UILabel!
}

final class EventDetailFeedbackTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var dateLabel: UILabel!
    
    @IBOutlet private(set) weak var reviewLabel: UILabel!
    
    @IBOutlet private(set) weak var ratingView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.ratingView.settings.updateOnTouch = false
    }
}
