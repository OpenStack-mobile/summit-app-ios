//
//  DataUpdateStrategyFactory.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class DataUpdateStrategyFactory: NSObject {
    public func create(className: String) -> IDataUpdateStrategy {
        var dataUpdateProcessStrategy: IDataUpdateStrategy
        switch className {
        case "MySchdedule":
            dataUpdateProcessStrategy = MyScheduleDataUpdateStrategy()
        default:
            dataUpdateProcessStrategy = DataUpdateStrategy()
        }
        return dataUpdateProcessStrategy
    }
}
