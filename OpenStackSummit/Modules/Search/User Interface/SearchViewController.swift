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

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ISearchViewController {

    @IBOutlet weak var attendeesTableView: UITableView!
    @IBOutlet weak var speakersTableView: UITableView!
    @IBOutlet weak var tracksTableView: UITableView!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchTermTextView: UITextField!

    private let eventsTableViewCellIdentifier = "scheduleTableViewCell"
    private let tracksTableViewCellIdentifier = "tracksTableViewCell"
    private let speakersTableViewCellIdentifier = "speakersTableViewCell"
    private let attendeesTableViewCellIdentifier = "attendeesTableViewCell"
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
        
        presenter.viewLoad()
    }

    func showErrorMessage(error: NSError) {
        
    }
    
    func reloadEvents() {
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.reloadData()
    }

    func reloadTracks() {
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
        tracksTableView.reloadData()
    }

    func reloadSpeakers() {
        speakersTableView.delegate = self
        speakersTableView.dataSource = self
        speakersTableView.reloadData()
    }
    
    func reloadAttendees() {
        attendeesTableView.delegate = self
        attendeesTableView.dataSource = self
        attendeesTableView.reloadData()
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
        else if (tableView == speakersTableView)  {
            let cell = tableView.dequeueReusableCellWithIdentifier(speakersTableViewCellIdentifier, forIndexPath: indexPath) as! PeopleTableViewCell
            presenter.buildSpeakerCell(cell, index: indexPath.row)
            return cell
        }
        else if (tableView == attendeesTableView)  {
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
        else if (tableView == speakersTableView) {
            presenter.getSpeakersCount()
        }
        else if (tableView == attendeesTableView) {
            presenter.getAttendeesCount()
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
        else if (tableView == speakersTableView) {
            count = presenter.getSpeakersCount()
        }
        else if (tableView == attendeesTableView) {
            count = presenter.getAttendeesCount()
        }
        return count
    }
    
    @IBAction func search(sender: AnyObject) {
        presenter.search(searchTermTextView.text)
    }
    
    override func viewWillDisappear(animated: Bool) {
        presenter.viewUnload()
    }
}
