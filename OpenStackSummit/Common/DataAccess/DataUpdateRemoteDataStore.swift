//
//  DataUpdateRemoteStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON
import AeroGearHttp
import AeroGearOAuth2
import Crashlytics

@objc
public protocol IDataUpdateRemoteDataStore {
    func getGeneralUpdatesAfterId(id: Int, completionBlock : ([DataUpdate]?, NSError?) -> Void)
}

public class DataUpdateRemoteDataStore: NSObject {

    var httpFactory: HttpFactory!
    var deserializerFactory: DeserializerFactory!
    
    func getGeneralUpdatesAfterId(id: Int, completionBlock : ([DataUpdate]?, NSError?) -> Void)  {
        let attendeeEndpoint = "\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current/entity-events"
        let http = httpFactory.create(HttpType.ServiceAccount)
        http.GET(attendeeEndpoint, parameters: nil) { (responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            if let json = responseObject as? NSString {
                let data = json.dataUsingEncoding(NSUTF8StringEncoding)
                let jsonObject = JSON(data: data!)
                
                var dataUpdates = [DataUpdate]()
                var dataUpdate: DataUpdate!
                let deserializer = self.deserializerFactory.create(DeserializerFactoryType.DataUpdate)
                for (_, dataUpdateJSON) in jsonObject {
                    do {
                        dataUpdate = try deserializer.deserialize(dataUpdateJSON) as! DataUpdate
                        dataUpdates.append(dataUpdate)
                    }
                    catch {
                        let nsError = error as NSError
                        Crashlytics.sharedInstance().recordError(nsError)
                        print(nsError.localizedDescription)
                    }
                }
                completionBlock(dataUpdates, error)
            }
            else {
                let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey :  NSLocalizedString("There was an error parsing data updates API response", value: "", comment: "")]
                let error = NSError(domain: Constants.ErrorDomain, code: 2001, userInfo: userInfo)
                completionBlock(nil, error)
            }
        }
    }
}
