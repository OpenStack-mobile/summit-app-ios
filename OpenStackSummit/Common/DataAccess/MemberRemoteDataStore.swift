//
//  MemberRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/28/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON
import AeroGearHttp
import AeroGearOAuth2
import Crashlytics

@objc
public protocol IMemberRemoteDataStore {
    func getLoggedInMember(completionBlock : (Member?, NSError?) -> Void)
    func getLoggedInMemberBasicInfo(completionBlock : (Member?, NSError?) -> Void)
    func getAttendeesForTicketOrder(orderNumber: String, completionBlock : ([NamedEntity]?, NSError?) -> Void)
}

public class MemberRemoteDataStore: NSObject, IMemberRemoteDataStore {
    var deserializerFactory: DeserializerFactory!
    var httpFactory: HttpFactory!
    
    public override init() {
        super.init()
    }
    
    public init(deserializerFactory: DeserializerFactory ) {
        self.deserializerFactory = deserializerFactory
    }
    
    public func getLoggedInMember(completionBlock : (Member?, NSError?) -> Void)  {
        let attendeeEndpoint = "\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current/attendees/me?expand=speaker,feedback,tickets"
        let http = httpFactory.create(HttpType.OpenIDGetFormUrlEncoded)
        http.GET(attendeeEndpoint, parameters: nil, completionHandler: {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            if let json = responseObject as? String {
                let deserializer = self.deserializerFactory.create(DeserializerFactoryType.Member)
                do {
                    let member = try deserializer.deserialize(json) as! Member                    
                    completionBlock(member, nil)
                }
                catch {
                    let nsError = error as NSError
                    print(nsError)
                    Crashlytics.sharedInstance().recordError(nsError)
                    let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey :  NSLocalizedString("There was an error performing operation", value: nsError.localizedDescription, comment: "")]
                    let friendlyError = NSError(domain: Constants.ErrorDomain, code: 8001, userInfo: userInfo)
                    completionBlock(nil, friendlyError)
                }
            }
        })
    }
    
    public func getLoggedInMemberBasicInfo(completionBlock : (Member?, NSError?) -> Void)  {
        let attendeeEndpoint = "\(Constants.Urls.AuthServerBaseUrl)/api/v1/users/me"
        let http = httpFactory.create(HttpType.OpenIDGetFormUrlEncoded)
        http.GET(attendeeEndpoint, parameters: nil, completionHandler: {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            if let json = responseObject as? String {
                let deserializer = self.deserializerFactory.create(DeserializerFactoryType.Member)
                do {
                    let member = try deserializer.deserialize(json) as! Member
                    completionBlock(member, nil)
                }
                catch {
                    let nsError = error as NSError
                    print(nsError)
                    Crashlytics.sharedInstance().recordError(nsError)
                    let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey :  NSLocalizedString("There was an error performing operation", value: nsError.localizedDescription, comment: "")]
                    let friendlyError = NSError(domain: Constants.ErrorDomain, code: 8001, userInfo: userInfo)
                    completionBlock(nil, friendlyError)
                }
            }
        })
    }
    
    public func getAttendeesForTicketOrder(orderNumber: String, completionBlock : ([NamedEntity]?, NSError?) -> Void) {
        let attendeeEndpoint = "\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current/external-orders/\(orderNumber)"
        let http = httpFactory.create(HttpType.OpenIDGetFormUrlEncoded)
        http.GET(attendeeEndpoint, parameters: nil, completionHandler: {(responseObject, error) in
           /* if (error != nil) {
                completionBlock(nil, error)
                return
            }
            if let json = responseObject as? String {
                let deserializer = self.deserializerFactory.create(DeserializerFactoryType.Member)
                do {
                    let member = try deserializer.deserialize(json) as! Member
                    completionBlock(member, nil)
                }
                catch {
                    let nsError = error as NSError
                    print(nsError)
                    Crashlytics.sharedInstance().recordError(nsError)
                    let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey :  NSLocalizedString("There was an error performing operation", value: nsError.localizedDescription, comment: "")]
                    let friendlyError = NSError(domain: Constants.ErrorDomain, code: 8001, userInfo: userInfo)
                    completionBlock(nil, friendlyError)
                }
            }*/
        })
    }
}
