//
//  RealmPerson.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public final class RealmPerson: BaseEntity {
    
    public dynamic var firstName = ""
    public dynamic var lastName = ""
    public dynamic var fullName = ""
    public dynamic var title = ""
    public dynamic var pictureUrl = ""
    public dynamic var bio = ""
    public dynamic var twitter = ""
    public dynamic var irc = ""
    public dynamic var email = ""
    public dynamic var location = ""
    public dynamic var memberId = 0
}

// MARK: - Encoding

extension Person: RealmEncodable {
    
    
}

extension Person: RealmDecodable {
    
    public init(realm: RealmEntity) {
        
        
    }
}