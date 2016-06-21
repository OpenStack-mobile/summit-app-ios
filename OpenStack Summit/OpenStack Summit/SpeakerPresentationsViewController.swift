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

final class SpeakerPresentationsViewController: ScheduleViewController, ShowActivityIndicatorProtocol, IndicatorInfoProvider {
    
    // MARK: - Loading
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Sessions")
    }
}