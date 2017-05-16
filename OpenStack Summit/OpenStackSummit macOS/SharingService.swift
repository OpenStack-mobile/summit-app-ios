//
//  SharingService.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/22/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit

extension NSSharingService {
    
    convenience init(copyLink link: String, title: String = "Copy Link") {
        
        self.init(title: title, image: NSImage(named: "copyLink")!, alternateImage: nil) {
            
            let pasteboard = NSPasteboard.general()
            
            pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
            
            let success = pasteboard.setString(link, forType: NSPasteboardTypeString)
            
            assert(success, "Could not copy to paste board")
        }
    }
}
