//
//  MemberRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/28/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberRemoteStorage {
    func addEventToShedule(memberId: Int, eventId: Int, completionBlock : (NSError?) -> Void)
}

public class MemberRemoteDataStore: NSObject {

    public func addEventToShedule(memberId: Int, eventId: Int, completionBlock : (NSError?) -> Void) {

        completionBlock(nil)
    }
}
