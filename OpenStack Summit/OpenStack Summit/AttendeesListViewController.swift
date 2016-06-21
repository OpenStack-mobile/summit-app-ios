//
//  AttendeesViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

final class AttendeesListViewController: UIViewController, PeopleListViewController, IndicatorInfoProvider {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var peopleListView: PeopleListView!
    
    // MARK: - Properties
    
    var searchTerm: String = ""
    
    var people = [PersonListItem]()
    
    var loadedAll = false
    
    // MARK: - Private Properties
    
    private var pageAttendees = 1
    
    // MARK: - Loading
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if pageAttendees == 1 {
            
            self.fetchData()
        }
        
        resetTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCell()
    }
    
    // MARK: - Methods
    
    func fetchData() {
        
        showActivityIndicator()
        /*
        interactor.getAttendeesByFilter(attendeesListViewController.searchTerm, page: pageAttendees, objectsPerPage: objectsPerPage) { attendeesPage, error in
            defer { self.attendeesListViewController.hideActivityIndicator() }
            
            if (error != nil) {
                self.attendeesListViewController.showErrorMessage(error!)
                return
            }
            
            self.attendees.appendContentsOf(attendeesPage!)
            self.attendeesListViewController.reloadData()
            self.loadedAllAttendees = attendeesPage!.count < self.objectsPerPage
            self.pageAttendees++
        }*/
    }
    
    func showPersonProfile(person: PersonListItem) {
        
        let memberProfileViewController = MemberProfileViewController()
        
        self.navigationController.pushViewController(memberProfileViewController, animated: true)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Attendees")
    }
}
