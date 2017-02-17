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
import EventKit
    
final class EventDetailViewController: UITableViewController, EventViewController, ShowActivityIndicatorProtocol, MessageEnabledViewController, TextViewController, ContextMenuViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) var feedBackHeader: EventDetailFeedbackHeader!
    
    @IBOutlet private(set) var speakersHeader: EventDetailHeader!
    
    // MARK: - Properties
    
    var event: Identifier!
    
    var eventRequestInProgress = false
    
    lazy var eventStore: EKEventStore = EKEventStore()
    
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
        
        if Store.shared.isLoggedIn {
            
            self.data.append(.actions)
        }
        
        self.data.append(.description)
        
        if eventDetail.location.isEmpty == false {
            
            data.append(.location)
        }
        
        if eventDetail.level.isEmpty == false {
            
            data.append(.level)
        }
        
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
        
        cell.nameLabel.text = feedback.member.name
        cell.ratingView.rating = Double(feedback.rate)
        cell.reviewLabel.text = feedback.review
        cell.dateLabel.text = feedback.date
        
        // set member image
        let placeholderImage = R.image.genericUserAvatar()!
        cell.memberImageView.hnk_setImageFromURL(NSURL(string: feedback.member.pictureURL)!, placeholder: placeholderImage)
    }
    
    private func configureAverageRatingView() {
        
        feedBackHeader.averageRatingLabel.hidden = loadingAverageRating
        feedBackHeader.averageRatingView.hidden = loadingAverageRating
        feedBackHeader.averageRatingLabel.text = "\(eventCache.averageFeedback)"
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
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.eventDetailDescriptionTableViewCell, forIndexPath: indexPath)!
                
                // date and time
                
                cell.eventDayLabel.text = eventDetail.day
                cell.eventTimeLabel.text = eventDetail.time
                
                // video
                
                cell.playButton.hidden = eventDetail.video == nil
                
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
                
            case .actions:
                
                let cell: EventDetailActionsTableViewCell
                
                if canAddFeedback(for: eventDetail) {
                    
                    cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.eventDetailActionsACell, forIndexPath: indexPath)!
                    
                } else {
                    
                    cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.eventDetailActionsBCell, forIndexPath: indexPath)!
                }
                
                let isFavorite = Store.shared.authenticatedMember?.isFavorite(event: event) ?? false
                
                let didConfirm = Store.shared.isEventScheduledByLoggedMember(event: event)
                
                cell.saveButton.actionLabel.text = isFavorite ? "Saved" : "Save"
                
                if eventDetail.rsvp.isEmpty {
                    
                    cell.confirmButton.actionLabel.text = didConfirm ? "Confirmed" : "Confirm"
                    
                } else {
                    
                    cell.confirmButton.actionLabel.text = didConfirm ? "RSVP'd" : "RSVP"
                }
                
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
                
                showLocationDetail(venue)
                
            case .level:
                
                let levelScheduleViewController = R.storyboard.schedule.levelScheduleViewController()!
                
                levelScheduleViewController.level = eventDetail.level
                
                self.showViewController(levelScheduleViewController, sender: self)
                
            default: break
            }
            
        case .speakers:
            
            let speaker = eventDetail.speakers[indexPath.row]
            
            let memberViewController = MemberProfileViewController(profile: MemberProfileIdentifier.speaker(speaker.identifier))
            
            self.showViewController(memberViewController, sender: self)
            
        case .feedback:
            
            let feedback = feedbackList[indexPath.row]
            
            let memberViewController = MemberProfileViewController(profile: MemberProfileIdentifier(member: feedback.member))
            
            self.showViewController(memberViewController, sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        
        let section = Section(rawValue: section)!
        
        switch section {
        case .details: return 0
        case .speakers: return eventDetail.speakers.isEmpty ? 0 : EventDetailHeader.height
        case .feedback: return shouldShowReviews ? EventDetailFeedbackHeader.height : 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let section = Section(rawValue: section)!
        
        switch section {
        case .details: return 0
        case .speakers: return eventDetail.speakers.isEmpty ? 0 : EventDetailHeader.height
        case .feedback: return shouldShowReviews ? EventDetailFeedbackHeader.height : 0
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let section = Section(rawValue: section)!
        
        switch section {
            
        case .details: return nil
        case .speakers: return eventDetail.speakers.isEmpty ? nil : speakersHeader
        case .feedback: return shouldShowReviews ? feedBackHeader : nil
        }
    }
    
    // MARK: - UITextViewDelegate
    
    // Swift Protocol extensions are not working entirely in ObjC, need to place implementation here and not in extension
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
        case description
        case actions
        case location
        case level
    }
}

final class EventDetailActionButton: Button {
    
    @IBOutlet weak var actionImageView: UIImageView!
    
    @IBOutlet weak var actionLabel: UILabel!
}

final class EventDetailHeader: UIView {
    
    static let height: CGFloat = 60.0
    
    @IBOutlet weak var label: UILabel!
}

final class EventDetailFeedbackHeader: UIView {
    
    static let height: CGFloat = 60.0
    
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var averageRatingView: CosmosView!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var averageRatingActivityIndicator: UIActivityIndicatorView!
}

final class EventDetailTitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var trackLabelHeightConstraint: NSLayoutConstraint!
}

final class EventDetailDescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventDayLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var playButton: Button!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var sponsorsLabel: UILabel!
    @IBOutlet weak var sponsorsLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sponsorsLabelSeparationConstraint: NSLayoutConstraint!
}

final class EventDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sectionLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
}

final class EventDetailActionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var saveButton: EventDetailActionButton!
    
    @IBOutlet weak var confirmButton: EventDetailActionButton!
    
    @IBOutlet weak var rateButton: EventDetailActionButton?
}

final class EventDetailFeedbackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var memberImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var reviewLabel: UILabel!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.ratingView.settings.updateOnTouch = false
        self.memberImageView.layer.masksToBounds = true
        self.memberImageView.layer.cornerRadius = CGRectGetWidth(self.memberImageView.bounds) / 2
    }
}
