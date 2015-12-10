//
//  FilterSection.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public enum FilterSectionType {
    case SummitType, EventType, Track, Tag, Level
}

public class FilterSection: NSObject {
    public var type : FilterSectionType!
    public var name = ""
    public var items = [FilterSectionItem]()
}
