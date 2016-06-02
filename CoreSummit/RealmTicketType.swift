//
//  RealmTicketType.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmTicketType: RealmEntity {
    
    public var name = ""
    public var ticketTypeDescription = ""
    public let allowedSummitTypes = List<RealmSummitType>()
}