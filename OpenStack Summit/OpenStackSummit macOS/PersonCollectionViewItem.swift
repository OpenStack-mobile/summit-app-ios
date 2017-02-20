//
//  PersonCollectionViewItem.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit

final class PersonCollectionViewItem: NSCollectionViewItem {

    func configure<T: Person>(with person: T) {
        
        textField!.stringValue = person.name
        
        imageView!.image = NSImage(named: "generic-user-avatar")
        
        if let url = NSURL(string: person.pictureURL) {
            
            imageView!.loadCached(url)
        }
    }
}
