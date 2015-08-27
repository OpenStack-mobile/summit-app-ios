//
//  SummitTypeDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol ISummitTypeDataStore {
    func getAll() -> [SummitType]
}

public class SummitTypeDataStore: BaseDataStore<SummitType>, ISummitTypeDataStore {
}

