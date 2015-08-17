//
//  SummitAttendee.swift
//  
//
//  Created by Claudio on 8/12/15.
//
//

import Foundation
import RealmSwift

public class SummitAttendee: BaseEntity {

    public dynamic var member : Member!
    let summitTypes = List<SummitType>()

}
