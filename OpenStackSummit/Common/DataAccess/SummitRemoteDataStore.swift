//
//  SummitRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AeroGearHttp
import AeroGearOAuth2
import SwiftyJSON
import RealmSwift

@objc
public protocol ISummitRemoteDataStore {
    func getActive(completionBlock : (Summit?, NSError?) -> Void)
}

public class SummitRemoteDataStore: NSObject, ISummitRemoteDataStore {
    var deserializerFactory: DeserializerFactory!

    public func getActive(completionBlock : (Summit?, NSError?) -> Void) {
        let http = Http(responseSerializer: StringResponseSerializer())
        let config = Config(
            base: "https://dev-identity-provider",
            authzEndpoint: "oauth2/auth",
            redirectURL: "org.openstack.ios.openstack-summit://oauthCallback",
            accessTokenEndpoint: "oauth2/token",
            clientId: "OpenID Client ID",
            revokeTokenEndpoint: "oauth2/token/revoke",
            isOpenIDConnect: true,
            userInfoEndpoint: "api/v1/users/info",
            scopes: ["openid", "https://dev-resource-server/summits/read"],
            clientSecret: "OpenID Secret"
        )
        
        let oauth2Module = AccountManager.addAccount(config, moduleClass: KeycloakOAuth2Module.self)
        http.authzModule = oauth2Module
        
        http.GET("https://dev-resource-server/api/v1/summits/current?expand=locations,sponsors,summit_types,event_types,presentation_categories,schedule") {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            /*let json = "{\"id\":1,\"name\":\"Tokio\",\"startDate\":1439936384,\"endDate\":1441000384,\"locations\":[{\"id\":1,\"name\":\"Grand Hotel\",\"description\": \"Description for the hotel\", \"address\":\"5th Avenue 4456\",\"lat\":\"45\",\"long\":\"33\",\"maps\":[{\"id\": 1, \"url\":\"http://www.openstack.org/assets/paris-summit/_resampled/resizedimage464600-meridien-map-level01.png\"}, {\"id\": 2, \"url\": \"https://www.openstack.org/assets/paris-summit/_resampled/resizedimage464600-merdien-map-level02.png\"}],\"rooms\":[{\"id\":1,\"name\":\"room1\",\"capacity\":1000},{\"id\":2,\"name\":\"room2\",\"capacity\":1200}]}],\"companies\":[{\"id\":1,\"name\":\"company1\"},{\"id\":2,\"name\":\"company2\"}],\"summitTypes\":[{\"id\":1,\"name\":\"main\"},{\"id\":2,\"name\":\"design\"}],\"eventTypes\":[{\"id\":1,\"name\":\"keynote\"},{\"id\":2,\"name\":\"presentation\"},{\"id\":3,\"name\":\"expo\"},{\"id\":4,\"name\":\"breakout\"}],\"presentationCategories\":[{\"id\":1,\"name\":\"category1\"},{\"id\":2,\"name\":\"category2\"},{\"id\":3,\"name\":\"category3\"},{\"id\":4,\"name\":\"category4\"}],\"events\":[{\"id\":1,\"title\":\"test event\",\"description\":\"this is a test event\",\"start\":1439936384,\"end\":1439946384,\"eventType\":1,\"summitTypes\":[1,2],\"sponsors\":[2],\"presentationCategory\":3,\"location\":2},{\"id\":2,\"title\":\"test event 2\",\"description\":\"this is a test event 2\",\"start\":1439986384,\"end\":1439996384,\"eventType\":1,\"summitTypes\":[2],\"sponsors\":[1],\"location\":1}]}"*/
            
            let json = responseObject as! NSString
            let data = json.dataUsingEncoding(NSUTF8StringEncoding)
            let jsonObject = JSON(data: data!)
            let summit : Summit
            var deserializer : IDeserializer!
            
            deserializer = self.deserializerFactory.create(DeserializerFactories.Summit)
            summit = deserializer.deserialize(jsonObject) as! Summit

            completionBlock(summit, error)
        }
    }
}
