//
//  SpeakerListViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

@objc final class SpeakerListViewController: UIViewController, PeopleListViewController, IndicatorInfoProvider {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var peopleListView: PeopleListView!
    
    // MARK: - Properties
    
    var searchTerm: String = ""
    
    var people = [PersonListItem]()
    
    var loadedAll = false
    
    // MARK: - Loading
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        resetTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
    // MARK: - Methods
    
    func fetchData() {
        
        
    }
    
    func showPersonProfile(person: PersonListItem) {
        
        
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Speakers")
    }
}
