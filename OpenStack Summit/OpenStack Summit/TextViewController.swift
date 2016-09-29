//
//  TextViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import UIKit
import CoreSummit
import RealmSwift

/// View Controller that contains a `UITextView`. Handles URLs internally in the app.
protocol TextViewController: class, UITextViewDelegate, SummitActivityHandlingViewController { }

extension TextViewController {
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        guard self.openWebURL(URL)
            else { return true }
        
        return false
    }
}