//
//  MenuInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/23/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AeroGearOAuth2
import Parse

@objc
public protocol IMenuInteractor {
    func login(completionBlock: (error: NSError?) -> Void)
    func logout(completionBlock: (error: NSError?) -> Void)
    func unsubscribeFromPushChannels(completionBlock: (succeeded: Bool, error: NSError?) -> Void)
    func getCurrentMember() -> MemberDTO?
}

public class MenuInteractor: NSObject, IMenuInteractor {
    let kAccessToken = "access_token"
    let kCurrentMember = "currentMember"
    
    var securityManager: SecurityManager!
    var memberDTOAssembler: IMemberDTOAssembler!
    var pushNotificationsManager: IPushNotificationsManager!
    var reachability: IReachability!
    
    public func login(completionBlock: (error: NSError?) -> Void) {
        if !reachability.isConnectedToNetwork() {
            let error = NSError(domain: "There is no network connectivity. Operation cancelled", code: 10001, userInfo: nil)
            completionBlock(error: error)
            return
        }
        
        securityManager.login() { error in
            if (error != nil) {
                completionBlock(error: error)
                return
            }
            
            self.pushNotificationsManager.subscribeToPushChannelsUsingContext(){ (succeeded: Bool, error: NSError?) in
                completionBlock(error: error)
            }
        }
    }

    public func logout(completionBlock: (error: NSError?) -> Void) {
        securityManager.logout() { error in
            if (error != nil) {
                completionBlock(error: error)
                return
            }
            
            self.pushNotificationsManager.unsubscribeFromPushChannels(){ (succeeded: Bool, error: NSError?) in
                completionBlock(error: error)
            }
        }
    }
    
    public func unsubscribeFromPushChannels(completionBlock: (succeeded: Bool, error: NSError?) -> Void) {
        pushNotificationsManager.unsubscribeFromPushChannels(completionBlock)
    }
    
    public func getCurrentMember() -> MemberDTO? {
        var memberDTO: MemberDTO?
        if let member = securityManager.getCurrentMember() {
            memberDTO = memberDTOAssembler.createDTO(member)
        }
        return memberDTO
    }
}
