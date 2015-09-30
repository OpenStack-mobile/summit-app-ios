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

public class DataUpdatePoller: NSObject, IDataUpdatePoller {
    public var pollingInterval: Double = 120
    var timer: NSTimer?
    var httpFactory: HttpFactory!
    var dataUpdateProcessor: DataUpdateProcessor!
    var dataUpdateDataStore: IDataUpdateDataStore!
    
    public override init() {
        super.init()
    }

    public init(httpFactory: HttpFactory, dataUpdateProcessor: DataUpdateProcessor, dataUpdateDataStore: IDataUpdateDataStore) {
        self.httpFactory = httpFactory
        self.dataUpdateProcessor = dataUpdateProcessor
        self.dataUpdateDataStore = dataUpdateDataStore
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
        
        http.GET("https://dev-resource-server/api/v1/summits/current/entity-events?last_event_id=\(latestDataUpdateId)") {(responseObject, error) in
            if (error != nil) {
                return
            }
            
            let json = responseObject as! String
            do {
                try self.dataUpdateProcessor.process(json)
            }
            catch {
                print("There was an error processing updates from server")
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
