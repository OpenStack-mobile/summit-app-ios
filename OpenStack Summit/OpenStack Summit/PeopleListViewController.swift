//
//  PeopleListViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

protocol PeopleListViewController: UITableViewDelegate, UITableViewDataSource, ShowActivityIndicatorProtocol {
    
    weak var peopleListView: PeopleListView! { get }
    
    var searchTerm: String { get }
    
    var people: [PersonListItem] { get }
    
    var loadedAll: Bool { get }
    
    func fetchData()
    
    func showPersonProfile(person: PersonListItem)
}

extension PeopleListViewController {
    
    @inline(__always)
    func resetTableView() {
        
        peopleListView.tableView.setContentOffset(CGPointZero, animated: false)
    }
    
    @inline(__always)
    func registerCell() {
        
        peopleListView.tableView.registerNib(R.nib.peopleTableViewCell)
    }
    
    @inline(__always)
    private func reloadData() {
        
        peopleListView.tableView.reloadData()
    }
    
    func configure(cell cell: PeopleTableViewCell, at indexPath: NSIndexPath) {
        
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
}

/*
internal class PeopleListViewControllerOld: UIViewController, UITableViewDelegate, UITableViewDataSource, ShowActivityIndicatorProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var peopleListView: PeopleListView!
    
    // MARK: - Properties
    
    var searchTerm: String = ""
    
    // MARK: - Private Properies
    
    private var people = [PersonListItem]()
    
    private var loadedAll = false
    
    // MARK: - Loading
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        peopleListView.tableView.setContentOffset(CGPointZero, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peopleListView.tableView.delegate = self
        peopleListView.tableView.dataSource = self
        
        peopleListView.tableView.registerNib(R.nib.peopleTableViewCell)
    }
    
    // MARK: - Methods
    
    
    
    // MARK: - Private Methods
    
    private func configure(cell cell: PeopleTableViewCell, at indexPath: NSIndexPath) {
        
        let row = indexPath.row
        
        let person = people[indexPath.row]
        
        cell.name = person.name
        cell.title = person.title
        cell.pictureURL = person.pictureURL
        
        /// fetch more
        if row == people.endIndex && loadedAll == false {
            
            
        }
    }
    
    @inline(__always)
    private func reloadData() {
        
        peopleListView.tableView.reloadData()
    }
    
    private func loadData() {
        
        
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
        
        showPersonProfile(indexPath)
    }
}*/