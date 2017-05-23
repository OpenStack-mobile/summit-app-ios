//
//  AppReview.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 5/19/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

extension UIViewController {
    
    /// Attempts to prompt the user to review the app in the App Store.
    ///
    /// This method is called after certain events occur 
    /// (e.g. event rated, video finished playing, about screen loaded)
    /// and can only show if the following requirements are met:
    /// - Running iOS 10.3 or above
    /// - App has been running for at least 5 minutes
    /// - It's been a week since we last prompted the user for a review.
    func requestAppReview() {
        
        guard canReviewApp
            else { return }
        
        // store new value
        Preference.lastAppReview = Date()
        
        // show UI
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    private var canReviewApp: Bool {
        
        let lastReview = Preference.lastAppReview
        
        // first prompt or interval after last prompt
        if let lastReview = lastReview {
            
            let interval: Double = 60 * 24 * 7 // 1 week
            
            return Date() >= lastReview.addingTimeInterval(interval)
            
        } else {
            
            let interval: Double = 60 * 5 // 5 min
            
            return Date() >= AppDelegate.shared.appLaunch.addingTimeInterval(interval)
        }
    }
}
