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
    
    var searchTerm: String = ""
    
    private(set) var people = [PresentationSpeaker]()
    
    private(set) var loadedAll = false
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = "SPEAKERS"
        
        addMenuButton()
        
        peopleListView.tableView.registerNib(R.nib.peopleTableViewCell)
        peopleListView.tableView.delegate = self
        peopleListView.tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        resetTableView()
    }
    
    // MARK: - Methods
    
    @IBAction func fetchData(sender: AnyObject? = nil) {
        
        
    }
    
    // MARK: - Private Methods
    
    private func showPersonProfile(person: PresentationSpeaker) {
        
        
    }
    
    @inline(__always)
    private func resetTableView() {
        
        peopleListView.tableView.setContentOffset(CGPointZero, animated: false)
    }
    
    @inline(__always)
    private func reloadTableView() {
        
        peopleListView.tableView.reloadData()
    }
    
    private func configure(cell cell: PeopleTableViewCell, at indexPath: NSIndexPath) {
        
        let row = indexPath.row
        
        let person = people[indexPath.row]
        
        cell.name = person.name
        cell.title = person.title
        cell.pictureURL = person.pictureURL
        
        /// fetch more
        if row == people.endIndex && loadedAll == false {
            
            fetchData()
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
        
        showPersonProfile(person)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Speakers")
    }
}
