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
        
        self.init(title: title, image: NSImage(named: NSImage.Name(rawValue: "copyLink"))!, alternateImage: nil) {
            
            let pasteboard = NSPasteboard.general
            
            pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
            
            let success = pasteboard.setString(link, forType: NSPasteboard.PasteboardType.string)
            
            assert(success, "Could not copy to paste board")
        }
    }
}
