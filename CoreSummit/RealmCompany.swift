//
//  RealmCompany.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmCompany: RealmNamed { }

// MARK: - Encoding

extension Company: RealmDecodable {
    
    public init(realmEntity: RealmCompany) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
    }
}