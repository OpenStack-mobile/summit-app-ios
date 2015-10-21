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
    var fromDate: Int {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("fromDateDataPoller") as? Int ?? 0
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "fromDateDataPoller")
        }
    }
    
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
        var url: String!
        if let latestDataUpdate = dataUpdateDataStore.getLatestDataUpdate() {
            url = "https://testresource-server.openstack.org/api/v1/summits/current/entity-events?last_event_id=\(latestDataUpdate.id)"
        }
        else {
            if fromDate == 0 {
                fromDate = Int(NSDate().timeIntervalSince1970)  - 60
            }
            url = "https://testresource-server.openstack.org/api/v1/summits/current/entity-events?from_date=\(fromDate)"
        }
        
        http.GET(url) {(responseObject, error) in
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
