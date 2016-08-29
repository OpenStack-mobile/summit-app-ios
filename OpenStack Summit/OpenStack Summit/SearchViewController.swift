//
//  SearchViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/22/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift
import CoreSummit

final class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, RevealViewController, MessageEnabledViewController {
    
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
            
            guard isViewLoaded() else { return }
            
            if searchTermTextView.text != searchTerm {
                
                searchTermTextView.text = searchTerm
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var events = [ScheduleItem]()
    private var tracks = [Track]()
    private var speakers = [PresentationSpeaker]()
    private let objectsPerPage = 1000
    private var pageSpeakers = 1
    private var loadedAllSpeakers = false
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
        
        // execute search
        if searchTerm.isEmpty == false {
            
            self.search()
        }
    }
    
    // MARK: - Actions
    
    /// Called by button in cell
    @IBAction func toggleScheduledStatus(sender: UIButton) {
        
        let button = sender
        let view = button.superview!
        let cell = view.superview as! ScheduleTableViewCell
        let indexPath = eventsTableView.indexPathForCell(cell)!
        let event = events[indexPath.row]
        
        let isScheduled = Store.shared.isEventScheduledByLoggedMember(event: event.id)
        
        if isOperationOngoing {
            return
        }
        
        isOperationOngoing = true
        
        // remove
        if isScheduled {
            
            cell.scheduled = false
            
            Store.shared.removeEventFromSchedule(event: event.id) { [weak self] (response) in
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    guard let controller = self else { return }
                    
                    controller.isOperationOngoing = false
                    
                    switch response {
                        
                    case let .Error(error):
                        
                        cell.scheduled = true
                        
                        controller.showErrorMessage(error as NSError)
                        
                    case .Value:
                        
                        break
                    }
                }
            }
        }
        
        // add
        else {
            
            cell.scheduled = true
            
            Store.shared.addEventToSchedule(event: event.id)  { [weak self] (response) in
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    guard let controller = self else { return }
                    
                    controller.isOperationOngoing = false
                    
                    switch response {
                        
                    case let .Error(error):
                        
                        cell.scheduled = false
                        
                        controller.showErrorMessage(error as NSError)
                        
                    case .Value:
                        
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func search() {
        
        loadedAllSpeakers = false
        pageSpeakers = 1
        speakers.removeAll()
        
        events = RealmSummitEvent.search(searchTerm).map { ScheduleItem(realmEntity: $0) }
        reloadEvents()
        tracks = Track.search(searchTerm)
        reloadTracks()
        
        getSpeakers()
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
        
        let speakersPage = PresentationSpeaker.filter(searchTerm, page: pageSpeakers, objectsPerPage: objectsPerPage)
        
        defer { self.loadingSpeakers = false }
        
        self.speakers.appendContentsOf(speakersPage)
        self.reloadSpeakers()
        self.loadedAllSpeakers = speakersPage.count < self.objectsPerPage
        self.pageSpeakers += 1
    }
    
    // MARK: Configure Table View Cells
    
    private func configure(cell cell: ScheduleTableViewCell, at indexPath: NSIndexPath) {
        
        let index = indexPath.row
        let event = events[index]
        cell.eventTitle = event.name
        cell.eventType = event.eventType
        cell.time = event.time
        cell.location = event.location
        cell.sponsors = event.sponsors
        cell.track = event.track
        cell.scheduled = Store.shared.isEventScheduledByLoggedMember(event: event.id)
        cell.isScheduledStatusVisible = Store.shared.isLoggedInAndConfirmedAttendee
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
        
        if let text = searchTermTextView.text where text.isEmpty == false {
            
            self.searchTerm = text
            self.search()
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
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.trackTableViewCell, forIndexPath: indexPath)!
            configure(cell: cell, at: indexPath)
            return cell
            
        case speakersTableView.tableView:
            
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
            
            let event = events[indexPath.row]
            
            let eventVC = R.storyboard.event.eventDetailViewController()!
            
            eventVC.event = event.id
            
            showViewController(eventVC, sender: self)
            
        case tracksTableView:
            
            let track = tracks[indexPath.row]
            
            let trackScheduleVC = R.storyboard.schedule.trackScheduleViewController()!
            
            trackScheduleVC.track = track
            
            self.showViewController(trackScheduleVC, sender: self)
            
        case speakersTableView.tableView:
            
            let speaker = speakers[indexPath.row]
            
            let memberProfileVC = MemberProfileViewController(profile: MemberProfileIdentifier(speaker: speaker))
            
            showViewController(memberProfileVC, sender: self)
            
        default: fatalError("Invalid table view: \(tableView)")
        }
    }
}
