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
import Crashlytics

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
        
        printdeb("Polling server for data updates")
        
        let http = securityManager.isLoggedIn() ? httpFactory.create(HttpType.OpenIDJson) : httpFactory.create(HttpType.ServiceAccount)
        var url: String!
        if let latestDataUpdate = dataUpdateDataStore.getLatestDataUpdate() {
            url = "\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current/entity-events?limit=50&last_event_id=\(latestDataUpdate.id)"
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
            
            url = "\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current/entity-events?limit=50&from_date=\(fromDate)"
        }
        
        http.GET(url) {(responseObject, error) in
            if (error != nil) {
                printerr("Error polling server for data updates: \(error)")
                Crashlytics.sharedInstance().recordError(error!)
                return
            }
            
            let json = responseObject as! String
            printdeb("Data updates: \(json)")

            do {
                try self.dataUpdateProcessor.process(json)
            }
            catch {
                let nsError = error as NSError
                printerr("There was an error processing updates from server: \(error)")
                let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey :  NSLocalizedString("There was an error processing updates from server: \(error)", value: nsError.localizedDescription, comment: "")]
                let friendlyError = NSError(domain: Constants.ErrorDomain, code: 1, userInfo: userInfo)
                Crashlytics.sharedInstance().recordError(friendlyError)
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    public func clearDataIfTruncateEventExist() {
        if let _ = dataUpdateDataStore.getTruncateDataUpdate() {
            genericDataStore.clearDataLocal({ (error) -> Void in
                self.fromDate = 0
                if self.securityManager.isLoggedIn() {
                    self.securityManager.logout({ (error) -> Void in
                    })
                }
            })
        }
    }
}
