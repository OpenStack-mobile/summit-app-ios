//
//  Person.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

public class Person: BaseEntity {
    public dynamic var firstName = ""
    public dynamic var lastName = ""
    public dynamic var title = ""
    public dynamic var pictureUrl = ""
    public dynamic var bio = ""
    public dynamic var twitter = ""
    public dynamic var irc = ""
    public dynamic var email = ""
    public dynamic var location = ""
}
