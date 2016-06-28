//
//  SearchViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/22/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

@objc final class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, RevealViewController, MessageEnabledViewController {
    
    // MARK: - IB Outlets

    @IBOutlet weak var speakersTableView: PeopleListView!
    @IBOutlet weak var tracksTableView: UITableView!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var searchTermTextView: UITextField!
    @IBOutlet weak var eventsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tracksTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var speakersTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    
    // MARK: - Properties

    var searchTerm: String = "" {
        
        didSet {
            
            if isViewLoaded() == false { self.loadView() }
            searchTermTextView.text = searchTerm
        }
    }
    
    // MARK: - Private Properties
    
    private var events = [ScheduleItem]()
    private var tracks = [Track]()
    private var speakers = [PresentationSpeaker]()
    private let objectsPerPage = 1000
    private var pageSpeakers = 1
    private var loadedAllSpeakers = false
    private var loadedAllAttendees = false
    private var loadingSpeakers = false
    private var isOperationOngoing = false
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMenuButton()
        
        // setup table view
        eventsTableView.registerNib(R.nib.scheduleTableViewCell)
        eventsTableView.estimatedRowHeight = 100
        eventsTableView.rowHeight = UITableViewAutomaticDimension
        
        speakersTableView.tableView.registerNib(R.nib.peopleTableViewCell)
        searchTermTextView.delegate = self
        
        //hack: if I don't add this constraint, width for table goes out of margins and height doesn't work well
        let tableWidthConstraint = NSLayoutConstraint(item: speakersTableView.tableView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: speakersTableView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        speakersTableView.addConstraint(tableWidthConstraint)
        let tableHeightConstraint = NSLayoutConstraint(item: speakersTableView.tableView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: speakersTableView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        speakersTableView.addConstraint(tableHeightConstraint)
        
        navigationItem.title = "SEARCH"
        
        search(searchTerm)
    }
    
    // MARK: - Actions
    
    /// Called by button in cell
    @IBAction func toggleScheduledStatus(sender: UIButton) {
        
        let button = sender
        let view = button.superview!
        let cell = view.superview as! ScheduleTableViewCell
        let indexPath = eventsTableView.indexPathForCell(cell)!
        let event = events[indexPath.row]
        
        let isScheduled = isEventScheduledByLoggedMember(event.id)
        
        if isScheduled {
            
            if isOperationOngoing {
                return
            }
            
            cell.scheduled = false
            
            isOperationOngoing = true
            
            interactor.removeEventFromLoggedInMemberSchedule(event.id) { error in
                dispatch_async(dispatch_get_main_queue(),{
                    if (error != nil) {
                        scheduleableView.scheduled = !scheduleableView.scheduled
                    }
                    
                    self.isOperationOngoing = false
                    
                    if (completionBlock != nil) {
                        completionBlock!(error)
                    }
                })
            }
            
        } else {
            
            
        }
        
        showErrorMessage(error!)
    }
    
    // MARK: - Private Methods
    
    private func search(searchTerm: String) {
        
        loadedAllSpeakers = false
        pageSpeakers = 1
        speakers.removeAll()
        
        events = getEventsBySearchTerm(searchTerm)
        reloadEvents()
        tracks = getTracksBySearchTerm(searchTerm)
        reloadTracks()
        
        getSpeakers()
    }
    
    func isEventScheduledByLoggedMember(eventId: Int) -> Bool {
        
        /*
         if !securityManager.isLoggedInAndConfirmedAttendee() {
         return false;
         }*/
        
        guard let loggedInMember = Store.shared.authenticatedMember,
            let attendee = loggedInMember.attendeeRole
            else { return false }
        
        return attendee.scheduledEvents.filter("id = \(eventId)").count > 0
    }
    
    private func setupTable(tableView: UITableView, withRowCount count: Int, withMinSize minSize:Int, withConstraint constraint: NSLayoutConstraint) {
        if count > 0 {
            constraint.constant = count <= 4 ? max(CGFloat(minSize), tableView.contentSize.height) : 290
            tableView.backgroundView = nil
        }
        else {
            constraint.constant = 40
            let label = UILabel()
            label.text = " No results"
            label.sizeToFit()
            tableView.backgroundView = label
        }
        tableView.frame.size.height = constraint.constant
    }
    
    // MARK: Fetch Data / Requests
    
    private func getSpeakers() {
        
        if loadingSpeakers || loadedAllSpeakers {
            return
        }
        
        loadingSpeakers = true
        
        getSpeakersBySearchTerm(searchTerm, page: pageSpeakers, objectsPerPage: objectsPerPage) { (speakersPage, error) in
            
            defer { self.loadingSpeakers = false }
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
                return
            }
            
            self.speakers.appendContentsOf(speakersPage!)
            self.viewController.reloadSpeakers()
            self.loadedAllSpeakers = speakersPage!.count < self.objectsPerPage
            self.pageSpeakers += 1
        }
    }
    
    private func addEventToLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> ()) {
        
        if Reachability.isConnectedToNetwork() == false {
            let error = NSError(domain: "There is no network connectivity. Operation cancelled", code: 12002, userInfo: nil)
            completionBlock(error)
            return
        }
        
        if let loggedInMember = securityManager.getCurrentMember() {
            let event = eventDataStore.getByIdLocal(eventId)
            
            summitAttendeeDataStore.addEventToMemberSchedule(loggedInMember.attendeeRole!, event: event!) {(attendee, error) in
                completionBlock(error)
            }
        }
    }
    
    
    // MARK: Configure Table View Cells
    
    private func configure(cell cell: ScheduleTableViewCell, at indexPath: NSIndexPath) {
        
        func isLoggedInAndConfirmedAttendee() -> Bool {
            
            // FIXME
            return false
        }
        
        let index = indexPath.row
        let event = events[index]
        cell.eventTitle = event.name
        cell.eventType = event.eventType
        cell.time = event.time
        cell.location = event.location
        cell.sponsors = event.sponsors
        cell.track = event.track
        cell.scheduled = isEventScheduledByLoggedMember(event.id)
        cell.isScheduledStatusVisible = isLoggedInAndConfirmedAttendee()
        cell.trackGroupColor = event.trackGroupColor != "" ? UIColor(hexaString: event.trackGroupColor) : nil
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.layoutSubviews()
        
        cell.scheduleButton.addTarget(self, action: #selector(SearchViewController.toggleScheduledStatus(_:)), forControlEvents: .TouchUpInside)
    }
    
    private func configure(cell cell: TrackTableViewCell, at indexPath: NSIndexPath) {
        
        let index = indexPath.row
        let track = tracks[index]
        cell.nameLabel.text = track.name
    }
    
    private func configure(cell cell: PeopleTableViewCell, at indexPath: NSIndexPath) {
        
        let index = indexPath.row
        
        let speaker = speakers[index]
        cell.name = speaker.name
        cell.title = speaker.title
        cell.pictureURL = speaker.pictureURL
        
        /// fetch more
        if (index == (speakers.count-1) && !loadedAllSpeakers) {
            
            getSpeakers()
        }
    }
    
    // MARK: Reload Table Views
    
    private func reloadEvents() {
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.reloadData()
        eventsTableView.layoutIfNeeded()
        setupTable(eventsTableView, withRowCount: eventsTableView.numberOfRowsInSection(0), withMinSize: 130, withConstraint: eventsTableViewHeightConstraint)
        eventsTableView.updateConstraintsIfNeeded()
    }

    private func reloadTracks() {
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
        tracksTableView.reloadData()
        tracksTableView.layoutIfNeeded()
        setupTable(tracksTableView, withRowCount: tracksTableView.numberOfRowsInSection(0), withMinSize: 50, withConstraint: tracksTableViewHeightConstraint)
        tracksTableView.updateConstraintsIfNeeded()
    }

    private func reloadSpeakers() {
        speakersTableView.tableView.delegate = self
        speakersTableView.tableView.dataSource = self
        speakersTableView.tableView.reloadData()
        speakersTableView.layoutIfNeeded()
        setupTable(speakersTableView.tableView, withRowCount: speakersTableView.tableView.numberOfRowsInSection(0), withMinSize: 60, withConstraint: speakersTableViewHeightConstraint)
        speakersTableView.updateConstraintsIfNeeded()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        searchTermTextView.resignFirstResponder()
        
        if searchTermTextView.text!.isEmpty == false {
            
            self.search(searchTermTextView.text ?? "")
        }
        
        return true
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
            
        case eventsTableView: return events.count
        case tracksTableView: return tracks.count
        case speakersTableView.tableView: return speakers.count
            
        default: fatalError("Invalid table view: \(tableView)")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch tableView {
            
        case eventsTableView:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.scheduleTableViewCell, forIndexPath: indexPath)!
            configure(cell: cell, at: indexPath)
            return cell
            
        case tracksTableView:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.tracksTableViewCell, forIndexPath: indexPath)!
            configure(cell: cell, at: indexPath)
            return cell
            
        case speakersTableView.view:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.peopleTableViewCell, forIndexPath: indexPath)!
            configure(cell: cell, at: indexPath)
            return cell
            
        default: fatalError("Invalid table view: \(tableView)")
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch tableView {
            
        case eventsTableView:
            
            
            
        case tracksTableView:
            
            
            
        case speakersTableView.view:
            
            
            
        default: fatalError("Invalid table view: \(tableView)")
        }
    }
}
