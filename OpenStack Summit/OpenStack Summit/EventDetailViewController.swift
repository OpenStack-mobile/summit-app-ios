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
import Foundation
import CoreSummit
import XCDYouTubeKit
import EventKit
import JGProgressHUD
import Predicate
    
final class EventDetailViewController: UITableViewController, EventViewController, ActivityViewController, MessageEnabledViewController, TextViewController, ContextMenuViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) var titleHeader: EventDetailTitleHeader!
    @IBOutlet private(set) var feedBackHeader: EventDetailFeedbackHeader!
    @IBOutlet private(set) var emptyFeedbackView: UIView!
    
    // MARK: - Properties
    
    var event: Identifier!
    var eventRequestInProgress = false
    lazy var eventStore: EKEventStore = EKEventStore()
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .dark)
    var contextMenu: ContextMenu { return contextMenu(for: eventDetail) }
    
    // MARK: - Private Properties
    
    private var eventCache: Event!
    private var eventDetail: EventDetail!
    private var data = [Detail]()
    private var entityController: EntityController<Event>!
    
    private var reviewsVisibility: ReviewsVisibility = .none
    private var loadingFeedback = false
    private var loadingAverageRating = false
    private var feedbackList = [FeedbackDetail]()
    private var loadedAllFeedback = false
    private var currentFeedbackPage: Page<Feedback>?
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addContextMenuBarButtonItem()
        
        // setup table view
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 60
        // must be set later, or else will trigger datasource methods with nil `self.eventDetail`
        defer { tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 20)) }
        // https://github.com/mac-cain13/R.swift/issues/144
        tableView.register(R.nib.tableViewHeaderViewLight(), forHeaderFooterViewReuseIdentifier: TableViewHeaderView.reuseIdentifier)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // handoff
        self.userActivity?.becomeCurrent()
        
        // update UI
        self.updateUI()
        
        // dont continue if no connectivity
        guard Reachability.connected else { return }
        
        // load feedback
        loadAverageRating()
        loadFeedback()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.userActivity?.resignCurrent()
    }
    
    override func updateUserActivityState(_ userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.event.rawValue,
                        AppActivityUserInfo.identifier.rawValue: self.event] as [String : Any]
        
        userActivity.addUserInfoEntries(from: userInfo as [AnyHashable: Any])
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Actions
    
    @IBAction func playVideo(_ sender: UIButton) {
        
        guard let video = eventDetail.video
            else { fatalError("No video") }
        
        self.play(video: video)
    }
    
    @IBAction func favoriteAction(_ sender: UIButton) {
        
        guard eventRequestInProgress == false else { return }
        
        guard Store.shared.isLoggedIn
            else { showErrorAlert("Login to use this function"); return }
        
        self.toggleFavorite(for: eventDetail)
    }
    
    @IBAction func scheduleAction(_ sender: UIButton) {
        
        guard eventRequestInProgress == false else { return }
        
        guard Store.shared.isLoggedInAndConfirmedAttendee
            else { showErrorAlert("Only attendees can use this function. Enter your EventBrite order number in my summit if you are an attendee."); return }
        
        self.toggleScheduledStatus(for: eventDetail)
    }
    
    @IBAction func rateAction(_ sender: UIButton) {
        
        guard Store.shared.isLoggedIn
            else { showErrorAlert("Login to use this function"); return }
        
        guard eventDetail.allowFeedback
            else { showErrorAlert("Feedback is not enabled for this event."); return }
        
        guard eventDetail.start < Date()
            else { showErrorAlert("Can only rate after event has started."); return }
        
        let viewController = self.feedbackController(for: eventDetail) { $0.dismiss(animated: true, completion: nil) }
        
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func rsvp(_ sender: AnyObject? = nil) {
        
        guard let url = eventDetail?.rsvp
            else { fatalError("No URL") }
        
        UIApplication.shared.openURL(url)
    }
    
    @IBAction func showAttachment(_ sender: AnyObject? = nil) {
        
        guard let url = eventDetail?.attachment
            else { fatalError("No URL") }
        
        UIApplication.shared.openURL(url)
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        guard let event = self.event
            else { fatalError("No identifier set") }
        
        let context = Store.shared.managedObjectContext
        
        // handle event deletion
        guard let eventManagedObject = try! EventManagedObject.find(event, context: context) else {
            
            self.view.isUserInteractionEnabled = false
            self.navigationItem.rightBarButtonItems = []
            showErrorAlert("The event has been deleted.",
                           okHandler: { self.navigationController?.popToRootViewController(animated: true) })
            return
        }
        
        self.eventCache = Event(managedObject: eventManagedObject)
        self.eventDetail = EventDetail(managedObject: eventManagedObject)
        
        self.data = []
        
        if eventDetail.video != nil {
            
            self.data.append(.video)
        }
        
        self.data.append(.description)
        
        if eventDetail.attachment != nil {
            
            data.append(.attachment)
        }
        
        if eventDetail.location.isEmpty == false {
            
            data.append(.location)
        }
        
        if eventDetail.level.isEmpty == false {
            
            data.append(.level)
        }
        
        // configure title header
        
        titleHeader.titleLabel.text = eventDetail.name
        titleHeader.trackLabel.text = eventDetail.track
        titleHeader.trackLabel.textColor = UIColor(hexString: eventDetail.trackGroupColor) ?? .white
        titleHeader.trackLabel.isHidden = eventDetail.track.isEmpty
        
        titleHeader.scheduleButton.setTitle(eventDetail.rsvp == nil ? "Schedule" : "RSVP", for: UIControlState())
        
        let didConfirm = Store.shared.isEventScheduledByLoggedMember(event: event)
        let isFavorite = Store.shared.authenticatedMember?.isFavorite(event: event) ?? false
        
        titleHeader.scheduleButton.isHighlighted = didConfirm
        titleHeader.favoriteButton.isHighlighted = isFavorite
        
        titleHeader.favoriteButton.isHidden = !eventDetail.willRecord

        // action buttons
        
        // get all reviews for this event
        let reviews = try! context.managedObjects(FeedbackManagedObject.self, predicate: "event.id" == event, sortDescriptors: FeedbackManagedObject.sortDescriptors)
        
        // can give feedback
        if reviews.isEmpty {
            
            reviewsVisibility = canAddFeedback(for: eventDetail) ? .showEmpty : .none
            
        } else {
            
            reviewsVisibility = .showReviews
        }
        
        feedbackList = reviews.map { FeedbackDetail(managedObject: $0) }
        
        // configure feedback view
        configureReviewCountView()
        configureAverageRatingView()
        
        // reload table
        self.tableView.reloadData()
        
        // set user activity for handoff
        let userActivity = NSUserActivity(activityType: AppActivity.view.rawValue)
        userActivity.title = eventDetail.name
        userActivity.webpageURL = eventDetail.webpage
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
            
            DispatchQueue.main.async {
                
                guard let controller = self else { return }
                
                assert(controller.loadingFeedback)
                
                controller.loadingFeedback = false
                
                switch response {
                    
                case let .error(error):
                    
                    print("Error loading feedback: \(error)")
                    
                case let .value(feedbackPage):
                    
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
            
            OperationQueue.main.addOperation { [weak self] in
                
                guard let controller = self else { return }
                
                controller.loadingAverageRating = false
                
                switch response {
                    
                case let .error(error):
                    
                    controller.showErrorMessage(error)
                    
                case .value:
                    
                    controller.configureAverageRatingView()
                }
            }
        }
    }
    
    private func configure(cell: PeopleTableViewCell, at indexPath: IndexPath) {
        
        assert(indexPath.section == Section.speakers.rawValue, "\(indexPath.section) is not speaker section")
        
        let speaker = eventDetail.speakers[indexPath.row]
        cell.name = speaker.name
        cell.title = speaker.title ?? ""
        cell.picture = speaker.picture
        cell.isModerator = speaker.isModerator
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero
    }
    
    private func configure(cell: EventDetailFeedbackTableViewCell, at indexPath: IndexPath) {
        
        assert(indexPath.section == Section.feedback.rawValue, "\(indexPath.section) is not feedback section")
        
        let feedback = feedbackList[indexPath.row]
        
        cell.ratingView.rating = Double(feedback.rate)
        cell.reviewLabel.text = feedback.review
        cell.dateLabel.text = feedback.date
    }
    
    private func configureAverageRatingView() {
        
        feedBackHeader.averageRatingLabel.isHidden = loadingAverageRating
        feedBackHeader.averageRatingView.isHidden = loadingAverageRating
        feedBackHeader.averageRatingLabel.text = "\(eventCache.averageFeedback)"
        feedBackHeader.averageRatingView.rating = eventCache.averageFeedback
        feedBackHeader.averageRatingActivityIndicator.isHidden = loadingAverageRating == false
        
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
            
            let cacheReviewCount = feedbackList.count
            
            let serverReviewCount = currentFeedbackPage?.total ?? 0
            
            let reviewCount = serverReviewCount > cacheReviewCount ? serverReviewCount : cacheReviewCount
            
            feedBackHeader.reviewsLabel.text = "\(reviewCount) Reviews"
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = Section(rawValue: section)!
        
        switch section {
        case .details: return data.count
        case .speakers: return eventDetail.speakers.count
        case .feedback: return reviewsVisibility == .showReviews ? feedbackList.count : 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = Section(rawValue: indexPath.section)!
        
        switch section {
            
        case .details:
            
            let detail = self.data[indexPath.row]
            
            switch detail {
                
            case .video:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventDetailVideoTableViewCell, for: indexPath)!
                
                guard let video = self.eventDetail?.video
                    else { fatalError("Event has no video") }
                
                cell.videoImageView.image = nil
                cell.playButton.isHidden = true
                cell.activityIndicator.isHidden = false
                cell.activityIndicator.startAnimating()
                
                guard let thumbnailURL = Foundation.URL(youtubeThumbnail: video.youtube)
                    else { return cell }
                
                cell.videoImageView.hnk_setImageFromURL(thumbnailURL.environmentScheme, success: { (image) in
                    
                    cell.playButton.isHidden = false
                    cell.activityIndicator.isHidden = true
                    cell.activityIndicator.stopAnimating()
                    cell.videoImageView.image = image
                })
                
                return cell
                
            case .description:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventDetailDescriptionTableViewCell, for: indexPath)!
                
                // date and time
                
                cell.eventDayLabel.text = eventDetail.day
                cell.eventTimeLabel.text = eventDetail.time
                
                // video
                
                cell.willRecordImageView.isHidden = eventDetail.willRecord == false
                
                // description text
                
                let eventDescriptionHTML = String(format:"<style>p:last-of-type { display:compact }</style><span style=\"font-family: OpenSans; font-size: 13\">%@</span>", eventDetail.eventDescription)
                if let data = eventDescriptionHTML.data(using: String.Encoding.unicode, allowLossyConversion: false),
                    let attrStr = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
                    
                    cell.descriptionTextView.attributedText = attrStr
                    
                } else {
                    
                    cell.descriptionTextView.text = ""
                }
                
                cell.descriptionTextView.textContainerInset = UIEdgeInsets.zero
                cell.descriptionTextView.delegate = self
                
                // sponsors
                cell.sponsorsLabel.text = eventDetail.sponsors
                cell.sponsorsLabelHeightConstraint.constant = eventDetail.sponsors.isEmpty ? 0 : 30
                cell.sponsorsLabelSeparationConstraint.constant = eventDetail.sponsors.isEmpty ? 0 : 8
                cell.sponsorsLabel.updateConstraints()
                
                return cell
                
            case .location:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventDetailTableViewCell, for: indexPath)!
                
                cell.sectionLabel.text = "VENUE"
                cell.valueLabel.text = eventDetail.location
                
                return cell
                
            case .level:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventDetailTableViewCell, for: indexPath)!
                
                cell.sectionLabel.text = "LEVEL"
                cell.valueLabel.text = eventDetail.level
                
                return cell
                
            case .attachment:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventDetailDownloadAttachmentTableViewCell, for: indexPath)!
                
                let title = eventDetail.eventType == "Presentation" ? "Download slides" : "Download attachment"
                cell.downloadButton.setTitle(title, for: .normal)
                
                return cell
            }
            
        case .speakers:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.speakerTableViewCell, for: indexPath)!
            
            configure(cell: cell, at: indexPath)
            
            return cell
            
        case .feedback:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventDetailFeedbackTableViewCell, for: indexPath)!
            
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = Section(rawValue: indexPath.section)!
        
        switch section {
            
        case .details:
            
            let detail = self.data[indexPath.row]
            
            switch detail {
                
            case .location:
                
                guard let venue = eventDetail.venue
                    else { return }
                
                show(location: venue.identifier)
                
            case .level:
                
                guard let level = eventCache.presentation.level
                    else { fatalError("No level for event:\n\(eventCache)") }
                
                let levelScheduleViewController = R.storyboard.schedule.levelScheduleViewController()!
                
                levelScheduleViewController.level = level
                
                self.show(levelScheduleViewController, sender: self)
                
            default: break
            }
            
        case .speakers:
            
            let speaker = eventDetail.speakers[indexPath.row]
            
            let memberViewController = MemberProfileViewController(profile: PersonIdentifier.speaker(speaker.identifier))
            
            self.show(memberViewController, sender: self)
            
        case .feedback:
            
            let feedback = feedbackList[indexPath.row]
            
            guard feedback.member.identifier == Store.shared.authenticatedMember?.id
                && canAddFeedback(for: eventDetail)
                else { return }
            
            let viewController = self.feedbackController(for: eventDetail) { $0.dismiss(animated: true, completion: nil) }
            
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        
        let section = Section(rawValue: section)!
        
        switch section {
            
        case .details:
            
            return EventDetailTitleHeader.estimatedHeight
            
        case .speakers:
            
            return eventDetail.speakers.isEmpty ? 0 : 60
            
        case .feedback:
            
            switch reviewsVisibility {
            case .none: return 0
            case .showEmpty: return 250
            case .showReviews: return EventDetailFeedbackHeader.height
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let section = Section(rawValue: section)!
        
        switch section {
            
        case .details:
            
            return UITableViewAutomaticDimension
            
        case .speakers:
            
            return eventDetail.speakers.isEmpty ? 0 : UITableViewAutomaticDimension
            
        case .feedback:
            
            switch reviewsVisibility {
            case .none: return 0
            case .showEmpty: return UITableViewAutomaticDimension
            case .showReviews: return EventDetailFeedbackHeader.height
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let section = Section(rawValue: section)!
        
        switch section {
            
        case .details:
            
            return titleHeader
            
        case .feedback:
            
            switch reviewsVisibility {
            case .none: return nil
            case .showEmpty: return emptyFeedbackView
            case .showReviews: return feedBackHeader
            }
            
        case .speakers:
            
            guard eventDetail.speakers.isEmpty == false
                else { return nil }
            
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewHeaderView.reuseIdentifier) as! TableViewHeaderView
            
            headerView.titleLabel.text = "SPEAKERS"
            
            return headerView
        }
    }
    
    // MARK: - UITextViewDelegate
    
    // Swift Protocol extensions are not visible to ObjC, need to place implementation here and not in extension
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        guard self.openWeb(url: URL)
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
        case attachment
        case location
        case level
    }
    
    enum ReviewsVisibility {
        
        case none
        case showReviews
        case showEmpty
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
    @IBOutlet private(set) weak var willRecordImageView: UIImageView!
    @IBOutlet private(set) weak var descriptionTextView: UITextView!
    @IBOutlet private(set) weak var sponsorsLabel: UILabel!
    @IBOutlet private(set) weak var sponsorsLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var sponsorsLabelSeparationConstraint: NSLayoutConstraint!
}

final class EventDetailTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var sectionLabel: UILabel!
    
    @IBOutlet private(set) weak var valueLabel: UILabel!
}

final class EventDetailDownloadAttachmentTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var downloadButton: UIButton!
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
