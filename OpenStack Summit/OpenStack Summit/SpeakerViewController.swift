//
//  SpeakerViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreSummit
import CoreData
import JGProgressHUD

final class SpeakerViewController: TableViewController, RevealViewController, IndicatorInfoProvider {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup navigation bar
        navigationItem.title = "SPEAKERS"
        addMenuButton()
        
        // setup table view
        self.tableView.registerNib(R.nib.peopleTableViewCell)
        self.tableView.estimatedRowHeight = 96
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // configure fetched results controller
        self.fetchedResultsController = NSFetchedResultsController(Speaker.self,
                                                                   delegate: self,
                                                                   sortDescriptors: Speaker.ManagedObject.sortDescriptors,
                                                                   sectionNameKeyPath: Speaker.ManagedObject.Property.firstName.rawValue,
                                                                   context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        // set user activity for handoff
        let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
        userActivity.title = "Speakers"
        userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.speakers.rawValue]
        userActivity.requiredUserInfoKeys = [AppActivityUserInfo.screen.rawValue]
        userActivity.becomeCurrent()
        
        self.userActivity = userActivity
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // reset Table View
        self.tableView.setContentOffset(CGPointZero, animated: false)
    }
    
    override func updateUserActivityState(userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.speakers.rawValue]
        
        userActivity.addUserInfoEntriesFromDictionary(userInfo as [NSObject : AnyObject])
        
        super.updateUserActivityState(userActivity)
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
