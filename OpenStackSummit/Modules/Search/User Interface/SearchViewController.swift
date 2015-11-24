//
//  SearchViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/22/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
protocol ISearchViewController {
    var navigationController: UINavigationController? { get }
    var presenter: ISearchPresenter! { get set }
    var searchTerm: String! { get set }
    func reloadEvents()
    func reloadTracks()
    func reloadSpeakers()
    func reloadAttendees()
    func showErrorMessage(error: NSError)
}

class SearchViewController: RevealViewController, UITableViewDelegate, UITableViewDataSource, ISearchViewController, UITextFieldDelegate {

    @IBOutlet weak var attendeesTableView: PeopleListView!
    @IBOutlet weak var speakersTableView: PeopleListView!
    @IBOutlet weak var tracksTableView: UITableView!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchTermTextView: UITextField!
    @IBOutlet weak var eventsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tracksTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attendeesTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var speakersTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!

    private let eventsTableViewCellIdentifier = "scheduleTableViewCell"
    private let tracksTableViewCellIdentifier = "tracksTableViewCell"
    private let speakersTableViewCellIdentifier = "peopleTableViewCell"
    private let attendeesTableViewCellIdentifier = "peopleTableViewCell"
    var presenter: ISearchPresenter!

    var searchTerm: String? {
        get {
            return searchTermTextView.text
        }
        set {
            searchTermTextView.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventsTableView.registerNib(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: eventsTableViewCellIdentifier)
        eventsTableView.estimatedRowHeight = 100
        eventsTableView.rowHeight = UITableViewAutomaticDimension
        
        //attendeesTableView.tableView.registerNib(UINib(nibName: "PeopleTableViewCell", bundle: nil), forCellReuseIdentifier: attendeesTableViewCellIdentifier)
        speakersTableView.tableView.registerNib(UINib(nibName: "PeopleTableViewCell", bundle: nil), forCellReuseIdentifier: speakersTableViewCellIdentifier)

        searchTermTextView.delegate = self
        
        //hack: if I don't add this constraint, width for table goes out of margins
        let tableWidthConstraint = NSLayoutConstraint(item: speakersTableView.tableView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: speakersTableView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        speakersTableView.addConstraint(tableWidthConstraint)
    }
    
    override func viewWillAppear(animated: Bool) {
        presenter.viewLoad()
    }

    func showErrorMessage(error: NSError) {
        
    }
    
    func reloadEvents() {
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.reloadData()
        setupTable(eventsTableView, forSize: eventsTableView.numberOfRowsInSection(0), withConstraint: eventsTableViewHeightConstraint)
        eventsTableView.updateConstraintsIfNeeded()
    }

    func reloadTracks() {
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
        tracksTableView.reloadData()
        setupTable(tracksTableView, forSize: tracksTableView.numberOfRowsInSection(0), withConstraint: tracksTableViewHeightConstraint)
        tracksTableView.updateConstraintsIfNeeded()
    }

    func reloadSpeakers() {
        speakersTableView.tableView.delegate = self
        speakersTableView.tableView.dataSource = self
        speakersTableView.tableView.reloadData()
        setupTable(speakersTableView.tableView, forSize: speakersTableView.tableView.numberOfRowsInSection(0), withConstraint: speakersTableViewHeightConstraint)
        speakersTableView.updateConstraintsIfNeeded()
    }
    
    func reloadAttendees() {
        attendeesTableView.tableView.delegate = self
        attendeesTableView.tableView.dataSource = self
        attendeesTableView.tableView.reloadData()
        setupTable(attendeesTableView.tableView, forSize: attendeesTableView.tableView.numberOfRowsInSection(0), withConstraint: attendeesTableViewHeightConstraint)
        attendeesTableView.updateConstraintsIfNeeded()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView == eventsTableView) {
            let cell = tableView.dequeueReusableCellWithIdentifier(eventsTableViewCellIdentifier, forIndexPath: indexPath) as! ScheduleTableViewCell
            presenter.buildEventCell(cell, index: indexPath.row)
            return cell
        }
        else if (tableView == tracksTableView) {
            let cell = tableView.dequeueReusableCellWithIdentifier(tracksTableViewCellIdentifier, forIndexPath: indexPath) as! TrackTableViewCell
            presenter.buildTrackCell(cell, index: indexPath.row)
            return cell
        }
        else if (tableView == speakersTableView.tableView)  {
            let cell = tableView.dequeueReusableCellWithIdentifier(speakersTableViewCellIdentifier, forIndexPath: indexPath) as! PeopleTableViewCell
            presenter.buildSpeakerCell(cell, index: indexPath.row)
            return cell
        }
        else if (tableView == attendeesTableView.tableView)  {
            let cell = tableView.dequeueReusableCellWithIdentifier(attendeesTableViewCellIdentifier, forIndexPath: indexPath) as! PeopleTableViewCell
            presenter.buildAttendeeCell(cell, index: indexPath.row)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if (tableView == eventsTableView) {
            count = presenter.getEventsCount()
        }
        else if (tableView == tracksTableView) {
            count = presenter.getTracksCount()
        }
        else if (tableView == speakersTableView.tableView) {
            count = presenter.getSpeakersCount()
        }
        else if (tableView == attendeesTableView.tableView) {
            count = presenter.getAttendeesCount()
        }
        return count
    }
    
    func setupTable(tableView: UITableView, forSize size: Int, withConstraint constraint: NSLayoutConstraint) {
        if size > 0 {
            constraint.constant = size <= 4 ? tableView.contentSize.height : 290
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchTermTextView.resignFirstResponder()
        presenter.search(searchTermTextView.text)
        return true
    }
}
