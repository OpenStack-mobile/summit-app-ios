//
//  SummitTypeDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISummitTypeDataStore {
    func getAllLocal() -> [SummitType]
    func getByIdLocal(id: Int) -> SummitType?
}

public class SummitTypeDataStore: GenericDataStore, ISummitTypeDataStore {
    public func getAllLocal() -> [SummitType] {
        return super.getAllLocal()
    }
    
    public func getByIdLocal(id: Int) -> SummitType? {
        return super.getByIdLocal(id)
    }
}

