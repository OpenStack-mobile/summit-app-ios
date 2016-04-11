//
//  MemberOrderConfirmInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

@objc
protocol IMemberOrderConfirmInteractor {
    func getAttendeesForTicketOrder(orderNumber: String, completionBlock: ([NamedDTO]?, NSError?) -> Void)
    func selectAttendeeFromOrderList(orderNumber: String, externalAttendeeId: Int, completionBlock: (NSError?) -> Void)
}

public class MemberOrderConfirmInteractor: NSObject, IMemberOrderConfirmInteractor {
    var memberDataStore: IMemberDataStore!
    var reachability: IReachability!
    var securityManager: SecurityManager!
    var namedDTOAssembler: NamedDTOAssembler!

    public func getAttendeesForTicketOrder(orderNumber: String, completionBlock: ([NamedDTO]?, NSError?) -> Void) {
        if !reachability.isConnectedToNetwork() {
            let error = NSError(domain: "There is no network connectivity. Operation cancelled", code: 15002, userInfo: nil)
            completionBlock(nil, error)
            return
        }
        
        if securityManager.isLoggedIn(){
            
            memberDataStore.getAttendeesForTicketOrderOrigin(orderNumber) { (var nonConfirmedAttendees, error) in
                
                if error != nil {
                    completionBlock(nil, error)
                    return
                }
                
                // this is for testing purposes only!!!
                /*var a = NonConfirmedSummitAttendee()
                a.id = 1
                a.name = "test name 1"
                nonConfirmedAttendees?.append(a)
                
                a = NonConfirmedSummitAttendee()
                a.id = 2
                a.name = "test name 2"
                nonConfirmedAttendees?.append(a)*/

                
                if let nonConfirmedAttendees = nonConfirmedAttendees {
                    var nonConfirmedSummitAttendeeDTO: NamedDTO
                    var dtos: [NamedDTO] = []
                    for nonConfirmedSummitAttendee in nonConfirmedAttendees {
                        nonConfirmedSummitAttendeeDTO = self.namedDTOAssembler.createDTO(nonConfirmedSummitAttendee)
                        dtos.append(nonConfirmedSummitAttendeeDTO)
                    }
                    
                    completionBlock(dtos, error)
                }
            }
        }
    }
    
    public func selectAttendeeFromOrderList(orderNumber: String, externalAttendeeId: Int, completionBlock: (NSError?) -> Void) {
        if !reachability.isConnectedToNetwork() {
            let error = NSError(domain: "There is no network connectivity. Operation cancelled", code: 15002, userInfo: nil)
            completionBlock(error)
            return
        }
        
        if securityManager.isLoggedIn(){
            
            memberDataStore.selectAttendeeFromOrderListOrigin(orderNumber, externalAttendeeId: externalAttendeeId) { error in
                if error != nil {
                    completionBlock(error)
                }
                self.securityManager.linkAttendeeIfExist(completionBlock)
            }
        }
    }
}
