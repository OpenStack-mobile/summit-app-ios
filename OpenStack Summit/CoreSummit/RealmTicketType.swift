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
        self.descriptionText = String(realm: realmEntity.ticketTypeDescription)
        self.allowedSummitTypes = realmEntity.allowedSummitTypes.identifiers
    }
}

extension TicketType: RealmEncodable {
    
    public func save(realm: Realm) -> RealmTicketType {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        realmEntity.ticketTypeDescription = descriptionText ?? ""
        realmEntity.allowedSummitTypes.replace(with: allowedSummitTypes)
        
        return realmEntity
    }
}