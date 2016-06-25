//
//  SpeakerPresentationsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/21/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftSpinner
import typealias CoreSummit.Identifier

final class SpeakerPresentationsViewController: ScheduleViewController, IndicatorInfoProvider {
    
    // MARK: - Properties
    
    // Required for view loading
    var speaker: Identifier!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(speaker != nil, "Speaker identifier not set")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Sessions")
    }
}