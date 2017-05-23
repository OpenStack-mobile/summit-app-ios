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
                                                                   sortDescriptors: SpeakerManagedObject.sortDescriptors,
                                                                   sectionNameKeyPath: #keyPath(SpeakerManagedObject.addressBookSectionName),
                                                                   context: Store.shared.managedObjectContext) as! NSFetchedResultsController<NSManagedObject>
        
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
    
    override func updateUserActivityState(_ userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.speakers.rawValue]
        
        userActivity.addUserInfoEntries(from: userInfo as [AnyHashable: Any])
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Private Methods
    
    private subscript (indexPath: IndexPath) -> Speaker {
        
        let managedObject = self.fetchedResultsController.object(at: indexPath) as! Speaker.ManagedObject
        
        return Speaker(managedObject: managedObject)
    }
    
    private func configure(cell: PeopleTableViewCell, at indexPath: IndexPath) {
        
        let person = self[indexPath]
        
        cell.name = person.name
        cell.title = person.title ?? ""
        cell.picture = person.picture
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.peopleTableViewCell)!
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let person = self[indexPath]
        
        let memberProfileVC = MemberProfileViewController(profile: PersonIdentifier(speaker: person))
        
        show(memberProfileVC, sender: self)
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        return self.fetchedResultsController.sectionIndexTitles
    }
    
    // MARK: - NSFetchedResultsControllerDataSource
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        
        return sectionName
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Speakers")
    }
}
