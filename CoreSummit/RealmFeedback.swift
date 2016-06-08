//
//  RealmFeedback.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift
import SwiftFoundation

public class RealmFeedback: RealmEntity {
    
    public dynamic var rate = 0
    public dynamic var review = ""
    public dynamic var date = NSDate(timeIntervalSince1970: 1)
    public dynamic var event: RealmSummitEvent!
    public dynamic var owner: RealmSummitAttendee!
}

// MARK: - Encoding

extension Feedback: RealmDecodable {
    
    public init(realmEntity: RealmFeedback) {
        
        self.identifier = realmEntity.id
        self.rate = realmEntity.rate
        self.review = realmEntity.review
        self.date = Date(foundation: realmEntity.date)
        self.event = realmEntity.event.id
        self.owner = realmEntity.owner.id
    }
}