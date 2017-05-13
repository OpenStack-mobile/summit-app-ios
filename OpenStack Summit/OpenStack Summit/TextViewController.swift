//
//  TextViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit

/// View Controller that contains a `UITextView`. Handles URLs internally in the app.
protocol TextViewController: class, UITextViewDelegate, SummitActivityHandlingViewController { }

extension TextViewController {
    
    func textView(_ textView: UITextView, shouldInteractWithURL URL: Foundation.URL, inRange characterRange: NSRange) -> Bool {
        
        guard self.openWeb(url: URL)
            else { return true }
        
        return false
    }
}
