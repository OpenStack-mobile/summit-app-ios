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
    }
    
    // MARK: - Actions
    
    @IBAction func toggleScheduledStatus(sender: UIButton) {
        
        let button = sender
        let view = button.superview!
        let cell = view.superview as! UITableViewCell
        let indexPath = eventsTableView.indexPathForCell(cell)
        
        toggleScheduledStatus(indexPath!.row, cell: view.superview as! ScheduleTableViewCell)
    }
    
    // MARK: - Private Methods
    
    private func search(searchTerm: String) {
        
        // FIXME: Implement search
        
        /*
        loadedAllSpeakers = false
        pageSpeakers = 1
        pageAttendees = 1
        speakers.removeAll()
        attendees.removeAll()
        
        events = interactor.getEventsBySearchTerm(searchTerm)
        viewController.reloadEvents()
        tracks = interactor.getTracksBySearchTerm(searchTerm)
        viewController.reloadTracks()
        
        getSpeakers()
        */
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
    
    // MARK: Configure Table View Cells
    
    private func configure(cell cell: ScheduleTableViewCell, at indexPath: NSIndexPath) {
        
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
        
        let index = indexPath.row
        let event = events[index]
        cell.eventTitle = event.name
        cell.eventType = event.eventType
        cell.time = event.time
        cell.location = event.location
        cell.sponsors = event.sponsors
        cell.track = event.track
        cell.scheduled = interactor.isEventScheduledByLoggedMember(event.id)
        cell.isScheduledStatusVisible = interactor.isLoggedInAndConfirmedAttendee()
        cell.trackGroupColor = event.trackGroupColor != "" ? UIColor(hexaString: event.trackGroupColor) : nil
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
            cell.scheduleButton.addTarget(self, action: #selector(SearchViewController.toggleScheduledStatus(_:)), forControlEvents: .TouchUpInside)
            
            presenter.buildEventCell(cell, index: indexPath.row)
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            cell.layoutSubviews()
            return cell
            
        case tracksTableView:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.tracksTableViewCell, forIndexPath: indexPath)!
            presenter.buildTrackCell(cell, index: indexPath.row)
            return cell
            
        case speakersTableView.view:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.peopleTableViewCell, forIndexPath: indexPath)!
            presenter.buildSpeakerCell(cell, index: indexPath.row)
            return cell
            
        default: fatalError("Invalid table view: \(tableView)")
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (tableView == eventsTableView) {
            presenter.showEventDetail(indexPath.row)
        }
        else if (tableView == tracksTableView) {
            presenter.showTrackEvents(indexPath.row)
        }
        else if (tableView == speakersTableView.tableView) {
            presenter.showSpeakerProfile(indexPath.row)
        }
        else if (tableView == attendeesTableView.tableView) {
            presenter.showAttendeeProfile(indexPath.row)
        }
    }
}
