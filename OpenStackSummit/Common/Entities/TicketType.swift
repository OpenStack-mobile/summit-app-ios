//
//  TicketType.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//


import UIKit
import RealmSwift

public class TicketType: RealmEntity {
    public var name = ""
    public var ticketTypeDescription = ""
    public let allowedSummitTypes = List<SummitType>()
}
