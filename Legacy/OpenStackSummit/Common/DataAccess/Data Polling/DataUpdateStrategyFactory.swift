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
    var summitVenueImageDataUpdateStrategy: SummitVenueImageDataUpdateStrategy!
    
    public func create(className: String) -> DataUpdateStrategy {
        var dataUpdateProcessStrategy: DataUpdateStrategy
        switch className {
        case "MySchedule":
            dataUpdateProcessStrategy = myScheduleDataUpdateStrategy
        case "SummitLocationImage", "SummitLocationMap":
            dataUpdateProcessStrategy = summitVenueImageDataUpdateStrategy
        default:
            dataUpdateProcessStrategy = genericDataUpdateProcessStrategy
        }
        return dataUpdateProcessStrategy
    }
}
