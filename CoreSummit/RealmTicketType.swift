//
//  RealmTicketType.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmTicketType: RealmNamed {
    
    public dynamic var ticketTypeDescription = ""
    public let allowedSummitTypes = List<RealmSummitType>()
}

// MARK: - Encoding

extension TicketType: RealmDecodable {
    
    public init(realmEntity: RealmTicketType) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.descriptionText = realmEntity.ticketTypeDescription
        self.allowedSummitTypes = SummitType.from(realm: realmEntity.allowedSummitTypes)
    }
}