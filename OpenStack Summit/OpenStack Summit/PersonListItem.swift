//
//  PersonListItem.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/20/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import CoreSummit

public struct PersonListItem: Named {
    
    // MARK: - Properties
    
    public let identifier: Identifier
    
    public let name: String
    
    public let title: String
    
    public let pictureURL: String
    
    // MARK: - Initialization
    
    public init(person: PresentationSpeaker) {
        
        self.identifier = person.identifier
        self.name = person.name
        self.title = person.title
        self.pictureURL = person.pictureURL
    }
}
