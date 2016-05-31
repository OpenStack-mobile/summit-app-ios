//
//  PersonListItem.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public protocol PersonListItemProtocol: Named {
    
    var title: String { get }
    var pictureURL: String { get }
    var attendee: Bool { get }
    var speaker: Bool { get }
}

public struct PersonListItem: PersonListItemProtocol {
    
    public let identifier: String
    public var name: String
    
    public var title: String
    public var pictureURL: String
    public var attendee: Bool
    public var speaker: Bool
}