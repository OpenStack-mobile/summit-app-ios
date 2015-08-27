//
//  FilterSection.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public enum FilterSectionTypes {
    case SummitType, EventType, Track
}

public class FilterSection: NSObject {
    public var type : FilterSectionTypes!
    public var items = [FilterSectionItem]()
}
