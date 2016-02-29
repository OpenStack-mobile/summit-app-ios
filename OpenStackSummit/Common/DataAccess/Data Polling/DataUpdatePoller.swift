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
    func startPollingIfNotPollingAlready()
    func clearDataIfTruncateEventExist()
}

public class DataUpdatePoller: NSObject, IDataUpdatePoller {
    public var pollingInterval: Double = 30
    var timer: NSTimer?
    var httpFactory: HttpFactory!
    var genericDataStore: GenericDataStore!
    var dataUpdateProcessor: DataUpdateProcessor!
    var dataUpdateDataStore: IDataUpdateDataStore!
    var summitDataStore: ISummitDataStore!
    var reachability: IReachability!
    var securityManager: SecurityManager!
    
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
    
    public init(httpFactory: HttpFactory, dataUpdateProcessor: DataUpdateProcessor, dataUpdateDataStore: IDataUpdateDataStore, summitDataStore: ISummitDataStore, reachability: IReachability, securityManager: SecurityManager) {
        self.httpFactory = httpFactory
        self.dataUpdateProcessor = dataUpdateProcessor
        self.dataUpdateDataStore = dataUpdateDataStore
        self.summitDataStore = summitDataStore
        self.reachability = reachability
        self.securityManager = securityManager
        
    }
    
    public func startPollingIfNotPollingAlready() {
        if timer != nil {
            return
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(pollingInterval, target: self, selector: "pollServer", userInfo: nil, repeats: true)
        pollServer()
    }
    
    func pollServer() {
        if !reachability.isConnectedToNetwork() {
            return
        }
        
        print("Polling server for data updates")
        
        let http = securityManager.isLoggedIn() ? httpFactory.create(HttpType.OpenIDJson) : httpFactory.create(HttpType.ServiceAccount)
        var url: String!
        if let latestDataUpdate = dataUpdateDataStore.getLatestDataUpdate() {
            url = "https://testresource-server.openstack.org/api/v1/summits/current/entity-events?last_event_id=\(latestDataUpdate.id)"
        }
        else {
            if fromDate == 0 {
                if let summit = summitDataStore.getActiveLocal() {
                    fromDate = Int(summit.initialDataLoadDate.timeIntervalSince1970)
                }
            }
            
            if (fromDate == 0) {
                return
            }
            
            url = "https://testresource-server.openstack.org/api/v1/summits/current/entity-events?from_date=\(fromDate)"
        }
        
        http.GET(url) {(responseObject, error) in
            if (error != nil) {
                print("Error polling server for data updates: \(error?.domain)")
                return
            }
            
            let json = responseObject as! String
            print("Data updates: \(json)")

            do {
                try self.dataUpdateProcessor.process(json)
            }
            catch {
                print("There was an error processing updates from server: \(error)")
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    public func clearDataIfTruncateEventExist() {
        if let _ = dataUpdateDataStore.getTruncateDataUpdate() {
            genericDataStore.clearDataLocal()
            fromDate = 0
            if securityManager.isLoggedIn() {
                securityManager.logout({ (error) -> Void in
                })
            }
        }
    }
}
