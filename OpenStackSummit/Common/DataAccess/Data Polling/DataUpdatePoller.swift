//
//  DataUpdatesPoller.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AeroGearHttp
import AeroGearOAuth2

@objc
public protocol IDataUpdatePoller {
    func startPolling()
}

public class DataUpdatePoller: NSObject {
    public var pollingInterval: Double = 120
    var timer: NSTimer?
    var httpFactory: HttpFactory!
    var dataUpdateProcessor: IDataUpdateProcessor!
    var dataUpdateDataStore: IDataUpdateDataStore!
    
    public override init() {
        super.init()
    }

    public init(httpFactory: HttpFactory, dataUpdateProcessor: IDataUpdateProcessor) {
        self.httpFactory = httpFactory
        self.dataUpdateProcessor = dataUpdateProcessor
    }
    
    public func startPolling() {
        timer = NSTimer.scheduledTimerWithTimeInterval(pollingInterval, target: self, selector: "pollServer", userInfo: nil, repeats: true)
        pollServer()
    }
    
    func pollServer() {
        let http = httpFactory.create(HttpType.ServiceAccount)
        var latestDataUpdateId = 0
        if let latestDataUpdate = dataUpdateDataStore.getLatestDataUpdate() {
            latestDataUpdateId = latestDataUpdate.id
        }
        
        http.GET("https://dev-resource-server/api/v1/summits/current?entity-events?last_event_id=\(latestDataUpdateId)") {(responseObject, error) in
            if (error != nil) {
                return
            }
            
            let json = responseObject as! String
            self.dataUpdateProcessor.process(json)
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
