//
//  DataUpdateStrategyFactory.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class DataUpdateStrategyFactory: NSObject {
    var genericDataUpdateProcessStrategy: DataUpdateStrategy!
    var myScheduleDataUpdateStrategy: MyScheduleDataUpdateStrategy!
    
    public func create(className: String) -> DataUpdateStrategy {
        var dataUpdateProcessStrategy: DataUpdateStrategy
        switch className {
        case "MySchdedule":
            dataUpdateProcessStrategy = myScheduleDataUpdateStrategy
        default:
            dataUpdateProcessStrategy = genericDataUpdateProcessStrategy
        }
        return dataUpdateProcessStrategy
    }
}
