//
//  SpeakersViewController.swift
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

final class SpeakersViewController: TableViewController, RevealViewController, IndicatorInfoProvider {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup navigation bar
        addMenuButton()
        
        // setup table view
        self.tableView.estimatedRowHeight = 96
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // configure fetched results controller
        self.fetchedResultsController = NSFetchedResultsController(Speaker.self,
                                                                   delegate: self,
                                                                   sortDescriptors: Speaker.ManagedObject.sortDescriptors,
                                                                   sectionNameKeyPath: Speaker.ManagedObject.Property.addressBookSectionName.rawValue,
                                                                   context: Store.shared.managedObjectContext)
        
        self.fetchedResultsController.fetchRequest.fetchBatchSize = 30
        try! self.fetchedResultsController.performFetch()
        
        // set user activity for handoff
        let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
        userActivity.title = "Speakers"
        userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.speakers.rawValue]
        userActivity.requiredUserInfoKeys = [AppActivityUserInfo.screen.rawValue]
        userActivity.becomeCurrent()
        
        self.userActivity = userActivity
    }
    
    override func updateUserActivityState(userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.speakers.rawValue]
        
        userActivity.addUserInfoEntriesFromDictionary(userInfo as [NSObject : AnyObject])
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Private Methods
    
    private subscript (indexPath: NSIndexPath) -> Speaker {
        
        let managedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Speaker.ManagedObject
        
        return Speaker(managedObject: managedObject)
    }
    
    private func configure(cell cell: PeopleTableViewCell, at indexPath: NSIndexPath) {
        
        let person = self[indexPath]
        
        cell.name = person.name
        cell.title = person.title
        cell.pictureURL = person.pictureURL
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.peopleTableViewCell)!
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let person = self[indexPath]
        
        let memberProfileVC = MemberProfileViewController(profile: PersonIdentifier(speaker: person))
        
        showViewController(memberProfileVC, sender: self)
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        
        return self.fetchedResultsController.sectionIndexTitles
    }
    
    // MARK: - NSFetchedResultsControllerDataSource
    
    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String? {
        
        return sectionName
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Speakers")
    }
}
