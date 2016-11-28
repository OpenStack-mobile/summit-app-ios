//
//  SpeakerListViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreSummit

final class SpeakerListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RevealViewController, ShowActivityIndicatorProtocol, IndicatorInfoProvider {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var peopleListView: PeopleListView!
    
    // MARK: - Properties
    
    private(set) var people = [Speaker]()
    
    private(set) var loadedAll = false
    
    private(set) var page = 1
    
    private(set) var objectsPerPage = 10
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup navigation bar
        navigationItem.title = "SPEAKERS"
        addMenuButton()
        
        // setup table view
        peopleListView.tableView.registerNib(R.nib.peopleTableViewCell)
        peopleListView.tableView.delegate = self
        peopleListView.tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // reset Table View
        peopleListView.tableView.setContentOffset(CGPointZero, animated: false)
        
        // load cached data
        loadData()
    }
    
    // MARK: - Methods
    
    /// Reloads the list of speakers from cache.
    @IBAction func loadData(sender: AnyObject? = nil) {
                
        let speakers = try! Speaker.filter(page: page, objectsPerPage: objectsPerPage, summit: self.currentSummit?.identifier, context: Store.shared.managedObjectContext)
        
        people.appendContentsOf(speakers)
        loadedAll = speakers.count < objectsPerPage
        page += 1
        
        peopleListView.tableView.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func configure(cell cell: PeopleTableViewCell, at indexPath: NSIndexPath) {
        
        let row = indexPath.row
        
        let person = people[indexPath.row]
        
        cell.name = person.name
        cell.title = person.title
        cell.pictureURL = person.pictureURL
        
        /// fetch more
        if row == (people.count - 1) && loadedAll == false {
            
            loadData()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return people.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.peopleTableViewCell)!
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let person = people[indexPath.row]
        
        let memberProfileVC = MemberProfileViewController(profile: MemberProfileIdentifier(speaker: person))
        
        showViewController(memberProfileVC, sender: self)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Speakers")
    }
}
